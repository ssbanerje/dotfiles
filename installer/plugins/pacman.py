#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import shutil
import subprocess

import dotbot


class Pacman(dotbot.Plugin):
    supports_dry_run = True

    _bootstrapYayDirective = 'bootstrapyay'
    _pacmanUpdateDirective = 'pacmanupdate'
    _yayUpdateDirective = 'yayupdate'
    _pacmanDirective = 'pacman'
    _yayDirective = 'yay'

    def __init__(self, context):
        super().__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False
        self._yay_bootstrapped = False

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
        cmd = (
            'rm -rf /tmp/yay-bin && '
            'git clone --depth 1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && '
            'echo "options+=(!debug)" >> /tmp/yay-bin/PKGBUILD && '
            '(cd /tmp/yay-bin && makepkg -si --needed --noconfirm) && '
            'rm -rf /tmp/yay-bin'
        )
        if self._run_command(cmd, self._sup_stdout, self._sup_stderr) != 0:
            self._log.error('Could not bootstrap yay-bin')
            return False
        self._yay_bootstrapped = True
        return True

    def _run_update(self, cmd='pacman'):
        if self._context.dry_run():
            self._log.action(f'Would update {cmd} packages')
            return True
        self._log.action(f'Updating {cmd} packages')
        return self._run_command(cmd + ' -Syu --noconfirm', True, False) == 0

    @staticmethod
    def _filter_missing(packages):
        try:
            res = subprocess.run(
                ['pacman', '-T', *packages],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=False,
            )
        except FileNotFoundError:
            return list(packages)
        if res.returncode == 0:
            return []
        if res.returncode == 127:
            return [line.strip() for line in res.stdout.splitlines() if line.strip()]
        return list(packages)

    def _install(self, packages, cmd='pacman'):
        missing = self._filter_missing(packages)
        if not missing:
            self._log.info(f"All {cmd} packages already installed: {' '.join(packages)}")
            return True
        pkgs = ' '.join(missing)
        if self._context.dry_run():
            self._log.action(f'Would install {cmd} packages: {pkgs}')
            return True
        self._log.action(f'Installing {cmd} packages: {pkgs}')
        res = self._run_command(
            cmd + ' -S --needed --noconfirm ' + pkgs,
            self._sup_stdout,
            self._sup_stderr,
        )
        if res != 0:
            self._log.warning(f'Could not install {pkgs}')
            return False
        return True

    def _install_packages(self, data, cmd='pacman'):
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

        for command in pre_commands:
            if self._context.dry_run():
                self._log.action(f'Would run command: {command}')
                continue
            self._log.debug('Running pre-installation command: ' + command)
            if self._run_command(command, self._sup_stdout, self._sup_stderr) != 0:
                self._log.error('Could not run command: ' + command)
                return False

        if packages and not self._install(packages, cmd):
            self._log.error('Could not install packages: ' + ' '.join(packages))
            return False

        for command in post_commands:
            if self._context.dry_run():
                self._log.action(f'Would run command: {command}')
                continue
            self._log.debug('Running post-installation command: ' + command)
            if self._run_command(command, self._sup_stdout, self._sup_stderr) != 0:
                self._log.error('Could not run command: ' + command)
                return False

        return True

    @staticmethod
    def use_sudo(cmd):
        return os.geteuid() != 0 and cmd.startswith('pacman')

    def _run_command(self, cmd, sup_stdout=True, sup_stderr=False):
        cmd_prefix = 'sudo -E ' if self.use_sudo(cmd) else ''
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
        )
