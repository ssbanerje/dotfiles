#!/usr/bin/env python3
import functools
import os
import sys

import yaml


def check_githubactions_yaml_configs(args=None):
    configs = [f.rsplit('.')[0] for f in os.listdir('meta/config/') if f.endswith('.yaml')]
    configs.remove('archlinux')
    with open('.github/workflows/build.yml') as github:
        try:
            yaml_configs = yaml.safe_load(github)
        except yaml.YAMLError as exc:
            print(exc)
    yaml_configs = yaml_configs['jobs']['test-config']['strategy']['matrix']['config']
    configs.sort()
    yaml_configs.sort()
    print(configs == yaml_configs)
    return configs == yaml_configs


def main(args=None):
    funcs = [check_githubactions_yaml_configs]
    return functools.reduce(lambda a, f: a and f(args), funcs, True)


if __name__ == '__main__':
    sys.exit(os.EX_OK if main() else os.EX_OSERR)
