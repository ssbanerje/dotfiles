#!/usr/bin/env python

import subprocess
import dotbot


class Npm(dotbot.Plugin):
    _directive = 'npm'

    def can_handle(self, directive):
        return directive == self._directive

    def handle(self, directive, data):
        if directive == self._directive:
            stdout = data.get('stdout', False)
            stderr = data.get('stderr', True)
            packages = ' '.join(data['packages'])
            self._log.info('Npm Global Install: %s' % packages)
            cmd = 'npm install -g %s' % (packages)
            return self._run_command(cmd, not stdout, not stderr) == 0
        else:
            raise ValueError('Cannot handle this directive %s' % directive)

    def _run_command(self, cmd, sup_stdout=True, sup_stderr=False):
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        return subprocess.call(cmd, stdout=stdout, stderr=stderr, shell=True, cwd=cwd)
