import os
import shutil
import subprocess
import tempfile

import dotbot


class Pacman(dotbot.Plugin):
    supports_dry_run = True

    _bootstrapYayDirective = 'bootstrapyay'
    _pacmanUpdateDirective = 'pacmanupdate'
    _yayUpdateDirective = 'yayupdate'
    _pacmanDirective = 'pacman'
    _yayDirective = 'yay'
    _YAY_REPO = 'https://aur.archlinux.org/yay-bin.git'

    def __init__(self, context):
        super().__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False
        self._yay_bootstrapped = False
        self._installed_cache = set()
        self._updated = set()

    def can_handle(self, directive):
        return directive in (
            self._bootstrapYayDirective,
            self._pacmanDirective,
            self._pacmanUpdateDirective,
            self._yayUpdateDirective,
            self._yayDirective,
        )

    def handle(self, directive, data):
        if directive == self._bootstrapYayDirective:
            return self._bootstrap_yay()
        if directive == self._pacmanUpdateDirective:
            return self._run_update('pacman')
        if directive == self._pacmanDirective:
            return self._install_packages(data, 'pacman')
        if directive == self._yayUpdateDirective:
            return self._bootstrap_yay() and self._run_update('yay')
        if directive == self._yayDirective:
            return self._bootstrap_yay() and self._install_packages(data, 'yay')
        msg = f'Cannot handle this directive {directive}'
        raise ValueError(msg)

    def _bootstrap_yay(self):
        if self._yay_bootstrapped or shutil.which('yay') is not None:
            self._log.info('yay is already installed')
            self._yay_bootstrapped = True
            return True
        if self._context.dry_run():
            self._log.action('Would bootstrap yay-bin from AUR')
            self._yay_bootstrapped = True
            return True
        self._log.action('Bootstrapping yay-bin from AUR')
        with tempfile.TemporaryDirectory(prefix='yay-bin-') as tmpdir:
            rc = self._run_command(
                ['git', 'clone', '--depth', '1', self._YAY_REPO, tmpdir],
                self._sup_stdout,
                self._sup_stderr,
            )
            if rc != 0:
                self._log.error('Could not clone yay-bin from AUR')
                return False
            pkgbuild = os.path.join(tmpdir, 'PKGBUILD')
            with open(pkgbuild, 'a', encoding='utf-8') as fh:
                fh.write('\noptions+=(!debug)\n')
            rc = self._run_command(
                ['makepkg', '-si', '--needed', '--noconfirm'],
                self._sup_stdout,
                self._sup_stderr,
                cwd=tmpdir,
            )
            if rc != 0:
                self._log.error('Could not build/install yay-bin')
                return False
        self._yay_bootstrapped = True
        return True

    def _run_update(self, cmd='pacman'):
        if cmd in self._updated:
            self._log.info(f'{cmd} packages already updated')
            return True
        if self._context.dry_run():
            self._log.action(f'Would update {cmd} packages')
            self._updated.add(cmd)
            return True
        self._log.action(f'Updating {cmd} packages')
        if (
            self._run_command(
                [cmd, '-Syu', '--noconfirm'], sup_stdout=True, sup_stderr=False
            )
            != 0
        ):
            return False
        self._updated.add(cmd)
        return True

    def _filter_missing(self, packages):
        uncached = [
            pkg for pkg in dict.fromkeys(packages) if pkg not in self._installed_cache
        ]
        if not uncached:
            return []
        try:
            res = subprocess.run(
                ['pacman', '-T', *uncached],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=False,
            )
        except FileNotFoundError:
            return uncached
        if res.returncode == 0:
            self._installed_cache.update(uncached)
            return []
        if res.returncode == 127:
            missing_set = {
                line.strip() for line in res.stdout.splitlines() if line.strip()
            }
            self._installed_cache.update(
                pkg for pkg in uncached if pkg not in missing_set
            )
            return [pkg for pkg in uncached if pkg in missing_set]
        return uncached

    def _install(self, packages, cmd='pacman'):
        missing = self._filter_missing(packages)
        if not missing:
            self._log.info(
                f'All {cmd} packages already installed: {" ".join(packages)}'
            )
            return True
        pkgs = ' '.join(missing)
        if self._context.dry_run():
            self._log.action(f'Would install {cmd} packages: {pkgs}')
            self._installed_cache.update(missing)
            return True
        self._log.action(f'Installing {cmd} packages: {pkgs}')
        res = self._run_command(
            [cmd, '-S', '--needed', '--noconfirm', *missing],
            self._sup_stdout,
            self._sup_stderr,
        )
        if res != 0:
            self._log.warning(f'Could not install {pkgs}')
            return False
        self._installed_cache.update(missing)
        return True

    def _install_packages(self, data, cmd='pacman'):
        packages = []
        for item in data:
            if isinstance(item, str):
                packages.append(item)
            elif isinstance(item, dict) and item:
                packages.append(next(iter(item)))
        if packages and not self._install(packages, cmd):
            self._log.error('Could not install packages: ' + ' '.join(packages))
            return False
        return True

    @staticmethod
    def use_sudo(cmd):
        return os.geteuid() != 0 and cmd == 'pacman'

    def _run_command(self, argv, sup_stdout=True, sup_stderr=False, cwd=None):
        cmd = ['sudo', '-E', *argv] if self.use_sudo(argv[0]) else list(argv)
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        workdir = cwd or self._context.base_directory()
        self._log.debug('Running command: ' + ' '.join(cmd))
        return subprocess.call(
            cmd,
            stdout=stdout,
            stderr=stderr,
            cwd=workdir,
        )
