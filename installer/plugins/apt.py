#!/usr/bin/env python
# -*- coding: utf-8 -*-

import subprocess
import dotbot
import os
from functools import reduce


class Apt(dotbot.Plugin):
    _aptDirective = 'apt'

    def can_handle(self, directive):
        return directive == self._aptDirective

    def handle(self, directive, data):
        if self._run_update() and (directive == self._aptDirective):
            return self._install_packages(data)
        else:
            raise ValueError("Cannot handle this directive %s" % directive)

    def _run_update(self):
        self._log.info("Updating APT repository")
        return self._run_command("apt update") == 0

    def _install(self, p):
        self._log.info("Installing %s" % p)
        res = self._run_command("apt install --yes %s" % p)
        if res != 0:
            self._log.warning("Could not install %s" % p)
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
        self._log.info("Running pre-installation commands")
        res = reduce(lambda x, y: x and y,
                     [self._run_command(c) == 0 for c in pre_commands], True)
        res = res and self._install(' '.join(packages))
        self._log.info("Running post-installation commands")
        res = res and reduce(
            lambda x, y: x and y,
            [self._run_command(c) == 0 for c in post_commands], True)

        return res

    def _run_command(self, cmd):
        cmd_prefix = "sudo " if os.geteuid() != 0 else ""
        return subprocess.call(cmd_prefix + cmd,
                               shell=True,
                               cwd=self._context.base_directory())
