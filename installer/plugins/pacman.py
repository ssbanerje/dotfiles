#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import shutil
import subprocess

import dotbot


class Pacman(dotbot.Plugin):
    _bootstrapYayDirective = 'bootstrapyay'
    _pacmanUpdateDirective = 'pacmanupdate'
    _yayUpdateDirective = 'yayupdate'
    _pacmanDirective = 'pacman'
    _yayDirective = 'yay'

    def __init__(self, context):
        super(Pacman, self).__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False

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
        raise ValueError('Cannot handle this directive %s' % directive)

    def _bootstrap_yay(self):
        if shutil.which('yay') is not None:
            self._log.info('yay is already installed')
            return True
        self._log.info('Bootstrapping yay-bin from AUR')
        cmd = (
            'rm -rf /tmp/yay-bin && '
            'git clone --depth 1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && '
            '(cd /tmp/yay-bin && makepkg -si --needed --noconfirm) && '
            'rm -rf /tmp/yay-bin'
        )
        if self._run_command(cmd, self._sup_stdout, self._sup_stderr) != 0:
            self._log.error('Could not bootstrap yay-bin')
            return False
        return True

    def _run_update(self, cmd='pacman'):
        self._log.info('Updating ' + cmd)
        return self._run_command(cmd + ' -Syu --noconfirm', True, False) == 0

    def _install(self, pkgs, cmd='pacman'):
        self._log.info('Installing %s' % pkgs)
        res = self._run_command(
            cmd + ' -S --needed --noconfirm ' + pkgs,
            self._sup_stdout,
            self._sup_stderr,
        )
        if res != 0:
            self._log.warning('Could not install %s' % pkgs)
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
            self._log.debug('Running pre-installation command: ' + command)
            if self._run_command(command, self._sup_stdout, self._sup_stderr) != 0:
                self._log.error('Could not run command: ' + command)
                return False

        pkgs = ' '.join(packages)
        if packages and not self._install(pkgs, cmd):
            self._log.error('Could not install packages: ' + pkgs)
            return False

        for command in post_commands:
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
