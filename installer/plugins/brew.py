#!/usr/bin/env python

import os
import shutil
import subprocess

import dotbot


class Brew(dotbot.Plugin):
    supports_dry_run = True

    _bootstrapDirective = 'bootstraphomebrew'
    _brewDirective = 'brew'
    _caskDirective = 'cask'
    _tapDirective = 'tap'
    _brewFileDirective = 'brewfile'

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

    @staticmethod
    def _brew_env():
        env = dict(os.environ)
        env.setdefault('HOMEBREW_NO_AUTO_UPDATE', '1')
        env.setdefault('HOMEBREW_NO_INSTALL_CLEANUP', '1')
        return env

    def _run_command(self, cmd, sup_stdout=True, sup_stderr=False):
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        return subprocess.call(
            cmd,
            stdout=stdout,
            stderr=stderr,
            shell=True,
            cwd=cwd,
            env=self._brew_env(),
        )

    def _get_installed(self, is_cask):
        if is_cask in self._installed_cache:
            return self._installed_cache[is_cask]
        if shutil.which('brew') is None:
            if self._context.dry_run():
                self._installed_cache[is_cask] = set()
                return self._installed_cache[is_cask]
            self._log.error('Homebrew is not installed')
            return None
        flag = '--cask' if is_cask else '--formula'
        res = subprocess.run(
            ['brew', 'list', flag, '-1'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=self._context.base_directory(),
            env=self._brew_env(),
            check=False,
        )
        if res.returncode != 0:
            self._log.error(f'Could not query installed Homebrew packages: {res.stderr.strip()}')
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
        if shutil.which('brew') is None:
            if self._context.dry_run():
                self._taps_cache = set()
                return self._taps_cache
            self._log.error('Homebrew is not installed')
            return None
        res = subprocess.run(
            ['brew', 'tap'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=self._context.base_directory(),
            env=self._brew_env(),
            check=False,
        )
        if res.returncode != 0:
            self._log.error(f'Could not query Homebrew taps: {res.stderr.strip()}')
            return None
        self._taps_cache = {line.strip().lower() for line in res.stdout.splitlines() if line.strip()}
        return self._taps_cache

    def _bootstrap_brew(self):
        if shutil.which('brew') is not None:
            self._log.info('Homebrew is already installed')
            return True
        if self._context.dry_run():
            self._log.action('Would bootstrap Homebrew')
            return True
        cmd = (
            '/bin/bash -c "$(curl -fsSL '
            'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        )
        self._log.action('Bootstrapping Homebrew')
        return self._run_command(cmd, self._sup_stdout, self._sup_stderr) == 0

    def _install_packages(self, packages, is_cask=False):
        installed = self._get_installed(is_cask)
        if installed is None:
            return False

        missing = []
        for pkg in packages:
            short = pkg.split('/')[-1]
            if pkg not in installed and short not in installed and short.rsplit('@', 1)[0] not in installed:
                missing.append(pkg)

        label = 'Homebrew casks' if is_cask else 'Homebrew formulae'
        if not missing:
            self._log.info(f"{label} already installed: {' '.join(packages)}")
            return True

        pkgs = ' '.join(missing)
        if self._context.dry_run():
            self._log.action(f'Would install {label}: {pkgs}')
        else:
            cask_opt = '--cask ' if is_cask else ''
            self._log.action(f'Installing {label}: {pkgs}')
            if self._run_command('brew install ' + cask_opt + pkgs, self._sup_stdout, self._sup_stderr) != 0:
                self._log.error(f'Failed to install {pkgs}')
                return False

        for pkg in missing:
            short = pkg.split('/')[-1]
            installed.add(pkg)
            installed.add(short)
            installed.add(short.rsplit('@', 1)[0])
        return True

    def _install_bundle(self, data):
        for bundle_file in data:
            if self._context.dry_run():
                self._log.action(f'Would install Brewfile {bundle_file}')
                continue
            self._log.action(f'Installing Brewfile {bundle_file}')
            res = self._run_command(
                f'brew bundle --file={bundle_file}',
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
            self._log.action(f'Tapping {tap}')
            cmd = f'brew tap {tap} && if brew trust --help >/dev/null 2>&1; then brew trust {tap}; fi'
            if self._run_command(cmd, self._sup_stdout, self._sup_stderr) != 0:
                self._log.warning(f'Failed to tap {tap}')
                return False
            taps.add(key)
        return True
