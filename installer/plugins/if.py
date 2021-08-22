#!/usr/bin/env python
# -*- coding: utf-8 -*-

import dotbot
from dotbot.dispatcher import Dispatcher
import distro


class IfPlatform(dotbot.Plugin):
    _directives = ['if'+d for d in [
        'macos',  # MacOS
        'ubuntu',  # Ubuntu
        'debian',  # Debian
        'rhel',  # RedHat Enterprise Linux
        'centos',  # CentOS
        'fedora',  # Fedora
        'sles',  # SUSE Linux Enterprise Server
        'opensuse',  # openSUSE
        'amazon',  # Amazon Linux
        'arch',  # Arch Linux
        'cloudlinux',  # CloudLinux OS
        'exherbo',  # Exherbo Linux
        'gentoo',  # GenToo Linux
        'ibm_powerkvm',  # IBM PowerKVM
        'kvmibm',  # KVM for IBM z Systems
        'linuxmint',  # Linux Mint
        'mageia',  # Mageia
        'mandriva',  # Mandriva Linux
        'parallels',  # Parallels
        'pidora',  # Pidora
        'raspbian',  # Raspbian
        'oracle',  # Oracle Linux (and Oracle Enterprise Linux)
        'scientific',  # Scientific Linux
        'slackware',  # Slackware
        'xenserver',  # XenServer
        'openbsd',  # OpenBSD
        'netbsd',  # NetBSD
        'freebsd',  # FreeBSD
        'midnightbsd',  # MidnightBSD
    ]]

    def can_handle(self, directive):
        return directive in self._directives

    def handle(self, directive, data):
        if directive not in self._directives:
            raise ValueError('Cannot handle this directive %s' % directive)

        did = distro.id()
        if did == 'darwin':
            did = 'macos'

        if directive == 'if'+did:
            self._log.debug('Matched paltform %s' % did)
            return self._run_internal(data)
        else:
            return True

    def _run_internal(self, data):
        dispatcher = Dispatcher(self._context.base_directory(),
                                only=self._context.options().only,
                                skip=self._context.options().skip,
                                options=self._context.options())
        return dispatcher.dispatch(data)
