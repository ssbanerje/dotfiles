#!/usr/bin/env python

import os
import shutil
import subprocess

import dotbot


class Brew(dotbot.Plugin):
    _bootstrapDirective = 'bootstraphomebrew'
    _brewDirective = 'brew'
    _caskDirective = 'cask'
    _tapDirective = 'tap'
    _brewFileDirective = 'brewfile'

    def __init__(self, context):
        super(Brew, self).__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False
        self._installed_cache = {}

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
        raise ValueError('Cannot handle this directive %s' % directive)

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
        flag = '--cask' if is_cask else '--formula'
        res = subprocess.run(
            ['brew', 'list', flag, '-1'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=self._context.base_directory(),
            env=self._brew_env(),
        )
        if res.returncode != 0:
            self._log.error('Could not query installed Homebrew packages: %s' % res.stderr.strip())
            return None
        names = set()
        for line in res.stdout.splitlines():
            token = line.strip()
            if token:
                names.add(token)
                names.add(token.rsplit('@', 1)[0])
        self._installed_cache[is_cask] = names
        return names

    def _bootstrap_brew(self):
        if shutil.which('brew') is not None:
            self._log.info('Homebrew is already installed')
            return True
        cmd = (
            '/bin/bash -c "$(curl -fsSL '
            'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        )
        self._log.info('Bootstrapping Homebrew')
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

        if not missing:
            self._log.info('Homebrew packages already installed: ' + ' '.join(packages))
            return True

        cask_opt = '--cask ' if is_cask else ''
        pkgs = ' '.join(missing)
        self._log.info('Homebrew install: ' + pkgs)
        if self._run_command('brew install ' + cask_opt + pkgs, self._sup_stdout, self._sup_stderr) != 0:
            self._log.error('Failed to install %s' % pkgs)
            return False

        for pkg in missing:
            short = pkg.split('/')[-1]
            installed.add(pkg)
            installed.add(short)
            installed.add(short.rsplit('@', 1)[0])
        return True

    def _install_bundle(self, data):
        for bundle_file in data:
            self._log.info('Installing from file %s' % bundle_file)
            res = self._run_command(
                'brew bundle --file=%s' % bundle_file,
                self._sup_stdout,
                self._sup_stderr,
            )
            if res != 0:
                self._log.warning('Failed to install file %s' % bundle_file)
                return False
        self._installed_cache.clear()
        return True

    def _install_tap(self, data):
        for tap in data:
            self._log.info('Tapping %s' % tap)
            cmd = (
                'brew tap %s && if brew trust --help >/dev/null 2>&1; then brew trust %s; fi'
                % (tap, tap)
            )
            if self._run_command(cmd, self._sup_stdout, self._sup_stderr) != 0:
                self._log.warning('Failed to tap %s' % tap)
                return False
        return True
