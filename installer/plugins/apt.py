#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import subprocess

import dotbot


class Apt(dotbot.Plugin):
    supports_dry_run = True

    _updateDirective = 'aptupdate'
    _aptDirective = 'apt'

    def __init__(self, context):
        super().__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False

    def can_handle(self, directive):
        return directive in (self._aptDirective, self._updateDirective)

    def handle(self, directive, data):
        if directive == self._updateDirective:
            return self._run_update()
        if directive == self._aptDirective:
            return self._install_packages(data)
        msg = f'Cannot handle this directive {directive}'
        raise ValueError(msg)

    def _run_update(self):
        if self._context.dry_run():
            self._log.action('Would update apt package lists')
            return True
        self._log.action('Updating apt package lists')
        return self._run_command('apt-get update', True, False) == 0

    @staticmethod
    def _is_installed(pkg):
        try:
            res = subprocess.run(
                ['dpkg-query', '-W', '-f=${db:Status-Status}', pkg],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=False,
            )
        except FileNotFoundError:
            return False
        return res.returncode == 0 and res.stdout.strip() == 'installed'

    def _install(self, packages):
        missing = [pkg for pkg in packages if not self._is_installed(pkg)]
        if not missing:
            self._log.info(f"All apt packages already installed: {' '.join(packages)}")
            return True
        pkgs = ' '.join(missing)
        if self._context.dry_run():
            self._log.action(f'Would install apt packages: {pkgs}')
            return True
        self._log.action(f'Installing apt packages: {pkgs}')
        res = self._run_command(
            'apt-get install --yes ' + pkgs,
            self._sup_stdout,
            self._sup_stderr,
        )
        if res != 0:
            self._log.warning(f'Could not install {pkgs}')
            return False
        return True

    def _install_packages(self, data):
        pre_commands = []
        post_commands = []
        packages = []
        for item in data:
            if isinstance(item, str):
                packages.append(item)
            elif isinstance(item, dict):
                name, opts = next(iter(item.items()))
                packages.append(name)
                pre_commands.extend(opts.get('shell_before', []))
                post_commands.extend(opts.get('shell_after', []))

        for cmd in pre_commands:
            if self._context.dry_run():
                self._log.action(f'Would run command: {cmd}')
                continue
            self._log.debug('Running pre-installation command: ' + cmd)
            if self._run_command(cmd, self._sup_stdout, self._sup_stderr) != 0:
                self._log.error('Could not run command: ' + cmd)
                return False

        if packages and not self._install(packages):
            self._log.error('Could not install packages: ' + ' '.join(packages))
            return False

        for cmd in post_commands:
            if self._context.dry_run():
                self._log.action(f'Would run command: {cmd}')
                continue
            self._log.debug('Running post-installation command: ' + cmd)
            if self._run_command(cmd, self._sup_stdout, self._sup_stderr) != 0:
                self._log.error('Could not run command: ' + cmd)
                return False

        return True

    def _run_command(self, cmd, sup_stdout=True, sup_stderr=False):
        env = dict(os.environ, DEBIAN_FRONTEND='noninteractive')
        cmd_prefix = 'sudo -E ' if os.geteuid() != 0 else ''
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        self._log.debug('Running command: ' + cmd)
        return subprocess.call(
            cmd_prefix + cmd,
            stdout=stdout,
            stderr=stderr,
            shell=True,
            cwd=cwd,
            env=env,
        )
