#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import subprocess

import dotbot


class Pacman(dotbot.Plugin):
    _pacmanUpdateDirective = 'pacmanupdate'
    _yayUpdateDirective = 'yayupdate'
    _pacmanDirective = 'pacman'
    _yayDirective = 'yay'

    def __init__(self, context):
        super(Pacman, self).__init__(context)
        self._sup_stdout = False if context.options().verbose > 0 else True
        self._sup_stderr = False

    def can_handle(self, directive):
        return directive in [self._pacmanDirective, self._pacmanUpdateDirective,
                             self._yayUpdateDirective, self._yayDirective]

    def handle(self, directive, data):
        if directive == self._pacmanUpdateDirective:
            return self._run_update('pacman')
        elif directive == self._pacmanDirective:
            return self._install_packages(data, 'pacman')
        elif directive == self._yayUpdateDirective:
            return self._run_update('yay')
        elif directive == self._yayDirective:
            return self._install_packages(data, 'yay')
        else:
            raise ValueError('Cannot handle this directive %s' % directive)

    def _run_update(self, cmd='pacman'):
        self._log.info('Updating '+cmd)
        return self._run_command(cmd + ' -Syu --noconfirm', True, False) == 0

    def _install(self, p, cmd='pacman'):
        self._log.info('Installing %s' % p)
        res = self._run_command(cmd + ' -S --noconfirm ' + p, self._sup_stdout, self._sup_stderr)
        if res != 0:
            self._log.warning('Could not install %s' % p)
            return False
        else:
            return True

    def _install_packages(self, data, cmd='pacman'):
        pre_commands = []
        post_commands = []
        packages = []
        for p in data:
            if isinstance(p, str):
                packages.append(p)
            elif isinstance(p, dict):
                n, o = list(p.items())[0]
                packages.append(n)
                try:
                    for c in o['shell_before']:
                        pre_commands.append(c)
                except KeyError:
                    pass
                try:
                    for c in o['shell_after']:
                        post_commands.append(c)
                except KeyError:
                    pass
        pkgs = ' '.join(packages)

        self._log.info('Running pre-installation commands')
        res = True
        for c in pre_commands:
            self._log.debug('Running pre-installation command: ' + c)
            res = res and (self._run_command(
                c, self._sup_stdout, self._sup_stderr) == 0)
            if not res:
                self._log.error('Could not run command: ' + c)
                return False

        self._log.debug('Installing packages: ' + pkgs)
        res = res and self._install(pkgs, cmd)
        if not res:
            self._log.error('Could not install packages: ' + pkgs)
            return False

        for c in post_commands:
            self._log.debug('Running post-installation command: ' + c)
            res = res and (self._run_command(
                c, self._sup_stdout, self._sup_stderr) == 0)
            if not res:
                self._log.error('Could not run command: ' + c)
                return False

        return res

    def use_sudo(self, cmd):
        is_not_root = os.geteuid() != 0
        using_pacman = cmd.startswith('pacman')
        return is_not_root and using_pacman

    def _run_command(self, cmd, sup_stdout=True, sup_stderr=False):
        cmd_prefix = 'sudo -E ' if self.use_sudo(cmd) else ''
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        self._log.debug('Running command: ' + cmd)
        return subprocess.call(cmd_prefix + cmd, stdout=stdout, stderr=stderr, shell=True, cwd=cwd)
