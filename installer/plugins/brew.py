import os
import shutil
import subprocess
import tempfile

import dotbot


class Brew(dotbot.Plugin):
    supports_dry_run = True

    _bootstrapDirective = 'bootstraphomebrew'
    _brewDirective = 'brew'
    _caskDirective = 'cask'
    _tapDirective = 'tap'
    _brewFileDirective = 'brewfile'
    _BREW_CANDIDATES = (
        '/opt/homebrew/bin/brew',
        '/usr/local/bin/brew',
        '/home/linuxbrew/.linuxbrew/bin/brew',
    )
    _INSTALL_URL = 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'

    def __init__(self, context):
        super().__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False
        self._installed_cache = {}
        self._taps_cache = None

    def can_handle(self, directive):
        return directive in (
            self._brewDirective,
            self._caskDirective,
            self._tapDirective,
            self._brewFileDirective,
            self._bootstrapDirective,
        )

    def handle(self, directive, data):
        if directive == self._brewDirective:
            return self._install_packages(data, is_cask=False)
        if directive == self._caskDirective:
            return self._install_packages(data, is_cask=True)
        if directive == self._brewFileDirective:
            return self._install_bundle(data)
        if directive == self._tapDirective:
            return self._install_tap(data)
        if directive == self._bootstrapDirective:
            return self._bootstrap_brew()
        msg = f'Cannot handle this directive {directive}'
        raise ValueError(msg)

    def _find_brew(self):
        found = shutil.which('brew')
        if found is None:
            for candidate in self._BREW_CANDIDATES:
                if os.path.isfile(candidate) and os.access(candidate, os.X_OK):
                    found = candidate
                    break
        if found is None:
            return None
        bin_dir = os.path.dirname(found)
        sbin_dir = os.path.join(os.path.dirname(bin_dir), 'sbin')
        path_parts = [p for p in os.environ.get('PATH', '').split(os.pathsep) if p]
        prepend = [
            d for d in (bin_dir, sbin_dir) if os.path.isdir(d) and d not in path_parts
        ]
        if prepend:
            os.environ['PATH'] = os.pathsep.join([*prepend, *path_parts])
        return found

    @staticmethod
    def _brew_env(extra=None):
        env = dict(os.environ)
        env.setdefault('HOMEBREW_NO_AUTO_UPDATE', '1')
        env.setdefault('HOMEBREW_NO_INSTALL_CLEANUP', '1')
        if extra:
            env.update(extra)
        return env

    def _run_command(self, argv, sup_stdout=True, sup_stderr=False, extra_env=None):
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        self._log.debug('Running command: ' + ' '.join(argv))
        return subprocess.call(
            argv,
            stdout=stdout,
            stderr=stderr,
            cwd=cwd,
            env=self._brew_env(extra_env),
        )

    def _get_installed(self, is_cask):
        if is_cask in self._installed_cache:
            return self._installed_cache[is_cask]
        brew = self._find_brew()
        if brew is None:
            if self._context.dry_run():
                self._installed_cache[is_cask] = set()
                return self._installed_cache[is_cask]
            self._log.error('Homebrew is not installed')
            return None
        flag = '--cask' if is_cask else '--formula'
        res = subprocess.run(
            [brew, 'list', flag, '-1'],
            capture_output=True,
            text=True,
            cwd=self._context.base_directory(),
            env=self._brew_env(),
            check=False,
        )
        if res.returncode != 0:
            self._log.error(
                f'Could not query installed Homebrew packages: {res.stderr.strip()}'
            )
            return None
        names = set()
        for line in res.stdout.splitlines():
            token = line.strip()
            if token:
                names.add(token)
                names.add(token.rsplit('@', 1)[0])
        self._installed_cache[is_cask] = names
        return names

    def _get_taps(self):
        if self._taps_cache is not None:
            return self._taps_cache
        brew = self._find_brew()
        if brew is None:
            if self._context.dry_run():
                self._taps_cache = set()
                return self._taps_cache
            self._log.error('Homebrew is not installed')
            return None
        res = subprocess.run(
            [brew, 'tap'],
            capture_output=True,
            text=True,
            cwd=self._context.base_directory(),
            env=self._brew_env(),
            check=False,
        )
        if res.returncode != 0:
            self._log.error(f'Could not query Homebrew taps: {res.stderr.strip()}')
            return None
        self._taps_cache = {
            line.strip().lower() for line in res.stdout.splitlines() if line.strip()
        }
        return self._taps_cache

    def _bootstrap_brew(self):
        if self._find_brew() is not None:
            self._log.info('Homebrew is already installed')
            return True
        if self._context.dry_run():
            self._log.action('Would bootstrap Homebrew')
            return True
        self._log.action('Bootstrapping Homebrew')
        with tempfile.TemporaryDirectory(prefix='homebrew-bootstrap-') as tmpdir:
            script = os.path.join(tmpdir, 'install.sh')
            if (
                self._run_command(
                    ['curl', '-fsSL', self._INSTALL_URL, '-o', script],
                    True,
                    self._sup_stderr,
                )
                != 0
            ):
                self._log.error('Failed to download Homebrew install script')
                return False
            rc = self._run_command(
                ['/bin/bash', script],
                self._sup_stdout,
                self._sup_stderr,
                extra_env={'NONINTERACTIVE': '1'},
            )
            if rc != 0:
                self._log.error('Failed to bootstrap Homebrew')
                return False
        if self._find_brew() is None:
            self._log.error(
                'Homebrew finished bootstrapping cleanly, but brew binary was not found'
            )
            return False
        return True

    def _install_packages(self, packages, is_cask=False):
        installed = self._get_installed(is_cask)
        if installed is None:
            return False

        missing = []
        for pkg in packages:
            short = pkg.split('/')[-1]
            if (
                pkg not in installed
                and short not in installed
                and short.rsplit('@', 1)[0] not in installed
            ):
                missing.append(pkg)

        label = 'Homebrew casks' if is_cask else 'Homebrew formulae'
        if not missing:
            self._log.info(f'{label} already installed: {" ".join(packages)}')
            return True

        pkgs = ' '.join(missing)
        if self._context.dry_run():
            self._log.action(f'Would install {label}: {pkgs}')
        else:
            brew = self._find_brew()
            if brew is None:
                self._log.error('Homebrew is not installed')
                return False
            argv = [brew, 'install', *(['--cask'] if is_cask else []), *missing]
            self._log.action(f'Installing {label}: {pkgs}')
            if self._run_command(argv, self._sup_stdout, self._sup_stderr) != 0:
                self._log.error(f'Failed to install {pkgs}')
                return False

        for pkg in missing:
            short = pkg.split('/')[-1]
            installed.add(pkg)
            installed.add(short)
            installed.add(short.rsplit('@', 1)[0])
        return True

    def _install_bundle(self, data):
        brew = self._find_brew()
        if brew is None and not self._context.dry_run():
            self._log.error('Homebrew is not installed')
            return False
        for bundle_file in data:
            if self._context.dry_run():
                self._log.action(f'Would install Brewfile {bundle_file}')
                continue
            self._log.action(f'Installing Brewfile {bundle_file}')
            res = self._run_command(
                [brew, 'bundle', f'--file={bundle_file}'],
                self._sup_stdout,
                self._sup_stderr,
            )
            if res != 0:
                self._log.warning(f'Failed to install file {bundle_file}')
                return False
        self._installed_cache.clear()
        self._taps_cache = None
        return True

    def _install_tap(self, data):
        taps = self._get_taps()
        if taps is None:
            return False
        for tap in data:
            key = tap.lower()
            if key in taps:
                self._log.info(f'Already tapped {tap}')
                continue
            if self._context.dry_run():
                self._log.action(f'Would tap {tap}')
                taps.add(key)
                continue
            brew = self._find_brew()
            if brew is None:
                self._log.error('Homebrew is not installed')
                return False
            self._log.action(f'Tapping {tap}')
            if (
                self._run_command(
                    [brew, 'tap', tap], self._sup_stdout, self._sup_stderr
                )
                != 0
            ):
                self._log.warning(f'Failed to tap {tap}')
                return False
            trust_probe = subprocess.run(
                [brew, 'trust', '--help'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                cwd=self._context.base_directory(),
                env=self._brew_env(),
                check=False,
            )
            if (
                trust_probe.returncode == 0
                and self._run_command(
                    [brew, 'trust', tap], self._sup_stdout, self._sup_stderr
                )
                != 0
            ):
                self._log.warning(f'Failed to trust tap {tap}')
                return False
            taps.add(key)
        return True
