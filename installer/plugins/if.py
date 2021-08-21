#!/usr/bin/env python
# -*- coding: utf-8 -*-

import dotbot
from dotbot.dispatcher import Dispatcher
import platform


class IfPlatform(dotbot.Plugin):
    _directive_if_macos = 'ifmacos'
    _directive_if_linux = 'iflinux'
    _directive_if_ubuntu = 'ifubuntu'

    def can_handle(self, directive):
        return directive in [
            self._directive_if_linux, self._directive_if_ubuntu, self._directive_if_macos
        ]

    def handle(self, directive, data):
        sys = platform.system()
        if sys == 'Darwin' and directive == self._directive_if_macos:
            return self._run_internal(data)
        elif sys == 'Linux':
            if directive == self._directive_if_linux:
                return self._run_internal(data)
            try:
                import distro
                dis = distro.linux_distribution()[0]
                if dis == 'Ubuntu' and directive == self._directive_if_ubuntu:
                    return self._run_internal(data)
            except ImportError:
                self._log.warning(
                    'Could not check distribution: pip install distro')
        return True

    def _run_internal(self, data):
        dispatcher = Dispatcher(self._context.base_directory(),
                                only=self._context.options().only,
                                skip=self._context.options().skip,
                                options=self._context.options())
        return dispatcher.dispatch(data)
