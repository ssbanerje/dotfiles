#!/usr/bin/env python3
# pylint: disable=line-too-long

import os
import sys
import yaml
import functools


def check_githubactions_yaml_configs(args=None):
    configs = [
        f.rsplit('.')[0] for f in os.listdir('meta/config/')
        if f.endswith('.yaml')
    ]
    with open('.github/workflows/build.yml') as github:
        try:
            yaml_configs = yaml.safe_load(github)
        except yaml.YAMLError as exc:
            print(exc)
    yaml_configs = yaml_configs['jobs']['install-config']['strategy']['matrix']['config']
    return configs.sort() == yaml_configs.sort()


def main(args=None):
    funcs = [check_githubactions_yaml_configs]
    return functools.reduce(lambda a, f: a and f(args), funcs, True)


if __name__ == '__main__':
    sys.exit(os.EX_OK if main() else os.EX_OSERR)
