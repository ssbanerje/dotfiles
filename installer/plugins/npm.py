#!/usr/bin/env python

import subprocess

import dotbot


class Npm(dotbot.Plugin):
    supports_dry_run = True

    _directive = 'npm'

    def can_handle(self, directive):
        return directive == self._directive

    @staticmethod
    def _is_installed(pkg):
        try:
            res = subprocess.run(
                ['npm', 'list', '-g', '--depth=0', pkg],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
        except FileNotFoundError:
            return False
        return res.returncode == 0

    def handle(self, directive, data):
        if directive != self._directive:
            msg = f'Cannot handle this directive {directive}'
            raise ValueError(msg)

        defaults = self._context.defaults().get(self._directive, {})
        if isinstance(data, list):
            package_list = data
            stdout = defaults.get('stdout', False)
            stderr = defaults.get('stderr', True)
        else:
            package_list = data['packages']
            stdout = data.get('stdout', defaults.get('stdout', False))
            stderr = data.get('stderr', defaults.get('stderr', True))

        missing = [pkg for pkg in package_list if not self._is_installed(pkg)]
        if not missing:
            self._log.info(f"Global npm packages already installed: {' '.join(package_list)}")
            return True

        packages = ' '.join(missing)
        if self._context.dry_run():
            self._log.action(f'Would install global npm packages: {packages}')
            return True

        self._log.action(f'Installing global npm packages: {packages}')
        cmd = f'npm install -g {packages}'
        return self._run_command(cmd, not stdout, not stderr) == 0

    def _run_command(self, cmd, sup_stdout=True, sup_stderr=False):
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        return subprocess.call(cmd, stdout=stdout, stderr=stderr, shell=True, cwd=cwd)
