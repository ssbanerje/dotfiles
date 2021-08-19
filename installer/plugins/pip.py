#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Taken from https://github.com/sobolevn/dotbot-pip/blob/master/pip.py (Commit: 4a6ba14)
#
#  MIT License
#
#  Copyright (c) 2017 Sobolev Nikita
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

import os
import subprocess
import dotbot


class Brew(dotbot.Plugin):
    _pipx_directive = 'pipx'
    _pipsi_directive = 'pipsi'
    _default_binary = 'pip'

    # Default outputs
    _default_stdout = False
    _default_stderr = False
    _use_user_directory = False

    _supported_directives = [
        'pip',  # it is not the same as default binary.
        _pipsi_directive,
        _pipx_directive,
    ]

    # API methods

    def can_handle(self, directive):
        return directive in self._supported_directives

    def handle(self, directive, data):
        data = self._maybe_convert_to_dict(data)

        try:
            self._do_requirements_exist(data)
            self._handle_install(directive, data)
            return True
        except ValueError as e:
            self._log.error(e)
            return False

    # Utility

    @property
    def cwd(self):
        return self._context.base_directory()

    # Inner logic

    def _maybe_convert_to_dict(self, data):
        if isinstance(data, str):
            return {'file': data}
        return data

    def _do_requirements_exist(self, data):
        message = 'Requirements file does not exist.'
        filename = data.get('file')
        if not filename:
            raise ValueError(message)

        path = os.path.join(self.cwd, filename)
        if not os.path.isfile(path):
            raise ValueError(message)

    def _get_binary(self, directive, data):
        """
        Return correct binary path.

        Respects `binary` key for `pip`.
        Returns just `pipsi` for `pipsi`.
        """
        if directive in [self._pipsi_directive, self._pipx_directive]:
            return directive

        return data.get('binary', self._default_binary)

    def _prepare_requirements(self, directive, data):
        """
        A tricky part. Resolving dependencies.

        `pipsi` does not support `requirements.txt` files.
        So we need to read all the requirements one by one and install
        them separately.

        And just return the file path with `-r` for `pip`.
        """
        if directive in [self._pipsi_directive, self._pipx_directive]:
            with open(os.path.join(self.cwd, data['file'])) as r:
                requirements = r.readlines()

            requirements = filter(
                lambda x: x != '\n' and not x.startswith('#'), requirements)
            return requirements

        # Just `pip`:
        return ['-r {}'.format(data['file'])]

    def _get_parameters(self, data):
        """
        Prepare the optional parameters
            :param self:
            :param data:
        """
        parameters = {
            'stdout': data.get('stdout', self._default_stdout),
            'stderr': data.get('stderr', self._default_stderr),
            'user_directory': data.get('user', self._use_user_directory),
        }
        return parameters

    # Handlers

    def _handle_install(self, directive, data):
        binary = self._get_binary(directive, data)
        requirements = self._prepare_requirements(directive, data)
        parameters = self._get_parameters(data)
        is_pip = directive == 'pip'

        param = ''
        if parameters['user_directory'] and is_pip:
            param = '--user'

        for req in requirements:
            command = '{} install {} {}'.format(binary, param, req)

            with open(os.devnull, 'w') as devnull:
                result = subprocess.call(
                    command,
                    shell=True,
                    stdin=devnull,
                    stdout=True if parameters["stdout"] else devnull,
                    stderr=True if parameters['stderr'] else devnull,
                    cwd=self.cwd,
                )

                if result not in [0, 1]:
                    raise ValueError('Failed to install requirements.')
