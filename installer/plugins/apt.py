import os
import re
import subprocess

import dotbot


class Apt(dotbot.Plugin):
    supports_dry_run = True

    _updateDirective = 'aptupdate'
    _aptDirective = 'apt'

    def __init__(self, context):
        super().__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False
        self._installed_cache = {}
        self._updated = False

    def can_handle(self, directive):
        return directive in (self._aptDirective, self._updateDirective)

    def handle(self, directive, data):
        if directive == self._updateDirective:
            return self._run_update()
        if directive == self._aptDirective:
            return self._install_packages(data)
        msg = f'Cannot handle this directive {directive}'
        raise ValueError(msg)

    def _run_update(self):
        if self._updated:
            self._log.info('Apt package lists already updated')
            return True
        if self._context.dry_run():
            self._log.action('Would update apt package lists')
            self._updated = True
            return True
        self._log.action('Updating apt package lists')
        if (
            self._run_command(['apt-get', 'update'], sup_stdout=True, sup_stderr=False)
            != 0
        ):
            return False
        self._updated = True
        return True

    def _query_installed(self, packages, refresh=False):
        targets = [
            pkg
            for pkg in dict.fromkeys(packages)
            if refresh or pkg not in self._installed_cache
        ]
        if not targets:
            return
        try:
            res = subprocess.run(
                [
                    'dpkg-query',
                    '-W',
                    '-f=${binary:Package}\t${Package}\t${Version}\t${db:Status-Status}\n',
                    *targets,
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                check=False,
            )
        except FileNotFoundError:
            return
        if res.returncode not in (0, 1):
            return
        for line in res.stdout.splitlines():
            parts = line.split('\t')
            if len(parts) != 4 or parts[3].strip() != 'installed':
                continue
            bin_pkg, pkg_name, version, _ = parts
            ver = version.strip()
            for key in (
                bin_pkg.strip(),
                pkg_name.strip(),
                bin_pkg.split(':', 1)[0].strip(),
            ):
                if key:
                    self._installed_cache[key] = ver

    @staticmethod
    def _get_candidates(packages):
        if not packages:
            return {}
        try:
            res = subprocess.run(
                ['apt-cache', 'policy', *dict.fromkeys(packages)],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                env=dict(os.environ, LC_ALL='C'),
                check=False,
            )
        except FileNotFoundError:
            return {}
        if res.returncode != 0:
            return {}
        candidates = {}
        current = None
        for line in res.stdout.splitlines():
            if line and not line[0].isspace() and line.endswith(':'):
                current = line[:-1].split(':', 1)[0]
            elif current and line.lstrip().startswith('Candidate:'):
                cand = line.split('Candidate:', 1)[1].strip()
                if cand and cand != '(none)':
                    candidates[current] = cand
                current = None
        return candidates

    @staticmethod
    def _version_satisfies(version, min_version):
        if not min_version:
            return True
        if not version:
            return False
        cmp_ver = version.split(':', 1)[-1] if ':' not in min_version else version
        try:
            res = subprocess.run(
                ['dpkg', '--compare-versions', cmp_ver, 'ge', min_version],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            return res.returncode == 0
        except FileNotFoundError:
            v_nums = tuple(
                int(part) for part in re.findall(r'\d+', cmp_ver.split('-', 1)[0])
            )
            m_nums = tuple(
                int(part) for part in re.findall(r'\d+', min_version.split('-', 1)[0])
            )
            pad = max(len(v_nums), len(m_nums))
            return v_nums + (0,) * (pad - len(v_nums)) >= m_nums + (0,) * (
                pad - len(m_nums)
            )

    @staticmethod
    def _parse_entries(data):
        entries = []
        items = data.items() if isinstance(data, dict) else data
        for item in items:
            if isinstance(item, str):
                entries.append((item, False, None))
            elif isinstance(item, tuple):
                name, opts = item
                opts = opts or {}
                min_ver = opts.get('min_version')
                entries.append(
                    (
                        name,
                        bool(opts.get('if_available', False)),
                        str(min_ver) if min_ver else None,
                    )
                )
            elif isinstance(item, dict) and item:
                name, opts = next(iter(item.items()))
                opts = opts or {}
                min_ver = opts.get('min_version')
                entries.append(
                    (
                        name,
                        bool(opts.get('if_available', False)),
                        str(min_ver) if min_ver else None,
                    )
                )
        return entries

    def _install_packages(self, data):
        entries = self._parse_entries(data)
        if not entries:
            return True

        all_names = [pkg for pkg, _, _ in entries]
        self._query_installed(all_names)

        need_policy = [
            pkg
            for pkg, if_avail, min_ver in entries
            if (if_avail or min_ver)
            and not self._version_satisfies(self._installed_cache.get(pkg), min_ver)
            and (pkg not in self._installed_cache or min_ver is not None)
        ]
        candidates = self._get_candidates(need_policy)

        present = []
        missing = []
        for pkg, if_avail, min_ver in entries:
            inst_ver = self._installed_cache.get(pkg)
            if inst_ver is not None and self._version_satisfies(inst_ver, min_ver):
                present.append(pkg)
                continue

            if if_avail or min_ver:
                cand = candidates.get(pkg)
                if cand is None:
                    if if_avail:
                        self._log.info(
                            f'Skipping optional apt package {pkg} (not available in apt)'
                        )
                        continue
                    if not self._context.dry_run():
                        self._log.error(f'Required apt package {pkg} is not available')
                        return False
                elif not self._version_satisfies(cand, min_ver):
                    if if_avail:
                        self._log.info(
                            f'Skipping optional apt package {pkg} (candidate {cand} < {min_ver})'
                        )
                        continue
                    self._log.error(
                        f'Apt candidate for {pkg} ({cand}) is older than required {min_ver}'
                    )
                    return False

            missing.append(pkg)

        if not missing:
            if present:
                self._log.info(
                    f'All apt packages already installed: {" ".join(present)}'
                )
            return True

        pkgs = ' '.join(missing)
        if self._context.dry_run():
            self._log.action(f'Would install apt packages: {pkgs}')
            for pkg, _, min_ver in entries:
                if pkg in missing:
                    self._installed_cache[pkg] = (
                        candidates.get(pkg) or min_ver or 'installed'
                    )
            return True

        self._log.action(f'Installing apt packages: {pkgs}')
        if (
            self._run_command(
                ['apt-get', 'install', '--yes', *missing],
                self._sup_stdout,
                self._sup_stderr,
            )
            != 0
        ):
            self._log.error(f'Could not install apt packages: {pkgs}')
            return False

        self._query_installed(missing, refresh=True)
        return True

    def _run_command(self, argv, sup_stdout=True, sup_stderr=False):
        env = dict(os.environ, DEBIAN_FRONTEND='noninteractive')
        cmd = ['sudo', '-E', *argv] if os.geteuid() != 0 else list(argv)
        stdout = subprocess.DEVNULL if sup_stdout else None
        stderr = subprocess.DEVNULL if sup_stderr else None
        cwd = self._context.base_directory()
        self._log.debug('Running command: ' + ' '.join(cmd))
        return subprocess.call(
            cmd,
            stdout=stdout,
            stderr=stderr,
            cwd=cwd,
            env=env,
        )
