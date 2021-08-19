#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import platform
import jinja2
import dotbot


class Template(dotbot.Plugin):
    _directive = 'template'

    def can_handle(self, directive):
        return directive == self._directive

    def handle(self, directive, data):
        if directive == self._directive:
            for temp in data:
                target, opts = list(temp.items())[0]
                target = os.path.expanduser(target)

                params = opts['params']
                params['HOME_DIR'] = os.environ['HOME']
                if '__UNAME__' in params:
                    uname = platform.system()
                    for k in params['__UNAME__'].keys():
                        params[k] = params['__UNAME__'][k][uname]
                    del params['__UNAME__']

                template_file = opts['source_file']
                template_dir = os.path.dirname(
                    os.path.abspath(self._context.base_directory() + '/' +
                                    template_file))
                jinja_env = jinja2.Environment(
                    loader=jinja2.FileSystemLoader(template_dir))
                template = jinja_env.get_template(
                    os.path.basename(template_file))

                with open(target, 'w') as target_file:
                    target_file.write(template.render(params))

            return True
        else:
            raise ValueError('Cannot handle this directive %s' % directive)
