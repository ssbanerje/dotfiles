#!/usr/bin/env python

import subprocess

import dotbot


class Brew(dotbot.Plugin):
    _bootstrapDirective = 'bootstraphomebrew'
    _brewDirective = 'brew'
    _caskDirective = 'cask'
    _tapDirective = 'tap'
    _brewFileDirective = 'brewfile'

    def __init__(self, context):
        super(Brew, self).__init__(context)
        self._sup_stdout = False if context.options().verbose > 0 else True
        self._sup_stderr = False

    def can_handle(self, directive):
        return directive in [
            self._brewDirective, self._caskDirective, self._tapDirective, self._brewFileDirective,
            self._bootstrapDirective
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
            raise ValueError('Cannot handle this directive %s' % directive)

    def _run_command(self, cmd, sub_stdout=True, sub_stderr=False):
        stdout = subprocess.DEVNULL if sub_stdout else None
        stderr = subprocess.DEVNULL if sub_stderr else None
        cwd = self._context.base_directory()
        return subprocess.call(cmd, stdout=stdout, stderr=stderr, shell=True, cwd=cwd)

    def _run_command_capture(self, cmd):
        cwd = self._context.base_directory()
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
                             cwd=cwd)
        return (res.returncode, res.stdout, res.stderr)

    def _bootstrap_brew(self):
        cmd = """hash brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
              brew update"""
        self._log.info('Bootstrapping Homebrew')
        res = self._run_command(cmd, self._sup_stdout, self._sup_stderr)
        if res != 0:
            return False
        else:
            return True

    def _install_packages(self, packages, isCask=False):
        cask_option = '--cask ' if isCask else ''
        cmd_pre = 'brew install ' + cask_option
        chk_pre = 'brew ls --versions ' + cask_option
        chk_pos = " | awk '{print $1}'"
        pkgs = ' '.join(packages)

        # Get installed packages
        (r, so, se) = self._run_command_capture(chk_pre + pkgs + chk_pos)
        if r != 0:
            self._log.error('Could not get installed homebrew packages')
            return False
        installed = so.decode('utf-8').split('\n')[:-1]
        installed = list(map(lambda x: x.rsplit('@')[0], installed))
        self._log.warning('Homebrew already installed: ' + ' '.join(installed))
        packages = [p for p in packages if p not in installed]

        # Install remaining packages
        if len(packages) == 0:
            return True
        self._log.info('Homebrew install: ' ' '.join(packages))
        if self._run_command(cmd_pre + ' '.join(packages), self._sup_stdout, self._sup_stderr) != 0:
            self._log.error('Failed to install %s' % p)
            return False
        return True

    def _install_bundle(self, data):
        for f in data:
            self._log.info('Installing from file %s' % f)
            res = self._run_command('brew bundle --file=%s' % f,
                                    self._sup_stdout, self._sup_stderr)
            if res != 0:
                self._log.warning('Failed to install file %f' % f)
                return False
        return True

    def _install_tap(self, data):
        for t in data:
            self._log.info('Tapping %s' % t)
            res = self._run_command('brew tap %s' % t,
                                    self._sup_stdout, self._sup_stderr)
            if res != 0:
                self._log.warning('Failed to tap %s' % t)
                return False
        return True
