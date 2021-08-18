#!/usr/bin/env python

import subprocess
import dotbot


class Brew(dotbot.Plugin):
    _bootstrapDirective = "bootstraphomebrew"
    _brewDirective = "brew"
    _caskDirective = "cask"
    _tapDirective = "tap"
    _brewFileDirective = "brewfile"

    def can_handle(self, directive):
        return directive in [
            self._brewDirective, self._caskDirective, self._tapDirective,
            self._brewFileDirective, self._bootstrapDirective
        ]

    def handle(self, directive, data):
        # Run the directive
        if directive == self._brewDirective:
            return self._install_packages(data, False)
        elif directive == self._caskDirective:
            return self._install_packages(data, True)
        elif directive == self._brewFileDirective:
            return self._install_bundle(data)
        elif directive == self._tapDirective:
            return self._install_tap(data)
        elif directive == self._bootstrapDirective:
            return self._bootstrap_brew()
        else:
            raise ValueError("Cannot handle this directive %s" % directive)

    def _run_command(self, cmd):
        return subprocess.call(cmd,
                               shell=True,
                               cwd=self._context.base_directory())

    def _bootstrap_brew(self):
        cmd = """hash brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
              brew update"""
        self._log.info('Bootstrapping Homebrew')
        res = self._run_command(cmd)
        if res != 0:
            return False
        else:
            return True

    def _install_packages(self, packages, isCask=False):
        cmd_prefix = "brew install{0}".format(" --cask" if isCask else "")
        chekcer_prefix = "brew ls --versions{0}".format(
            " --cask" if isCask else "")
        for p in packages:
            isInstalled = self._run_command(chekcer_prefix + " %s" % p)
            if isInstalled != 0:
                self._log.info("Installing %s" % p)
                res = self._run_command(cmd_prefix + " %s" % p)
                if res != 0:
                    self._log.warning('Failed to install %s' % p)
                    return False
        return True

    def _install_bundle(self, data):
        for f in data:
            self._log.info("Installing from file %s" % f)
            res = self._run_command("brew bundle --file=%s" % f)
            if res != 0:
                self._log.warning("Failed to install file %f" % f)
                return False
        return True

    def _install_tap(self, data):
        for t in data:
            self._log.info("Tapping %s" % t)
            res = self._run_command("brew tap %s" % t)
            if res != 0:
                self._log.warning('Failed to tap %s' % t)
                return False
        return True
