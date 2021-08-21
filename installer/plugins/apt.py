#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import subprocess

import dotbot


class Apt(dotbot.Plugin):
    _updateDirective = 'aptupdate'
    _aptDirective = 'apt'

    def __init__(self, context):
        super(Apt, self).__init__(context)
        self._sup_stdout = False if context.options().verbose > 0 else True
        self._sup_stderr = False

    def can_handle(self, directive):
        return directive in [self._aptDirective, self._updateDirective]

    def handle(self, directive, data):
        if directive == self._updateDirective:
            return self._run_update()
        elif directive == self._aptDirective:
            return self._install_packages(data)
        else:
            raise ValueError('Cannot handle this directive %s' % directive)

    def _run_update(self):
        self._log.info('Updating APT repository')
        return self._run_command('apt update', True, False) == 0

    def _install(self, p):
        self._log.info('Installing %s' % p)
        res = self._run_command('apt install --yes ' + p, self._sup_stdout, self._sup_stderr)
        if res != 0:
            self._log.warning('Could not install %s' % p)
            return False
        else:
            return True

    def _install_packages(self, data):
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
            res = res and (self._run_command(c, self._sup_stdout, self._sup_stderr) == 0)
            if not res:
                self._log.error('Could not run command: ' + c)
                return False

        res = res and self._install(pkgs)
        if not res:
            self._log.error('Could not install packages: ' + pkgs)
            return False

        self._log.info('Running post-installation commands')
        for c in post_commands:
            res = res and (self._run_command(c, self._sup_stdout, self._sup_stderr) == 0)
            if not res:
                self._log.error('Could not run command: ' + c)
                return False

        return res

    def _run_command(self, cmd, sup_stdout=True, sup_stderr=False):
        cmd_prefix = 'sudo -E ' if os.geteuid() != 0 else ''
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        self._log.debug('Running command: '+ cmd)
        return subprocess.call(cmd_prefix + cmd, stdout=stdout, stderr=stderr, shell=True, cwd=cwd)
