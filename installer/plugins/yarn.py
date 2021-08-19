#!/usr/bin/env python

import subprocess
import dotbot


class Yarn(dotbot.Plugin):
    _directive = "yarn"

    def can_handle(self, directive):
        return directive == self._directive

    def handle(self, directive, data):
        # Run the directive
        if directive == self._directive:
            cmd = "yarn global upgrade && yarn global add %s" % (
                ' '.join(data))
            print(cmd)
            return self._run_command(cmd) == 0
        else:
            raise ValueError("Cannot handle this directive %s" % directive)

    def _run_command(self, cmd):
        return subprocess.call(cmd,
                               shell=True,
                               cwd=self._context.base_directory())
