import gzip
import os
import platform
import re
import shutil
import stat
import subprocess
import tarfile
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import zipfile

import dotbot


class GhRelease(dotbot.Plugin):
    supports_dry_run = True

    _directive = 'ghrelease'

    def __init__(self, context):
        super().__init__(context)
        self._sup_stdout = context.options().verbose <= 0
        self._sup_stderr = False

    def can_handle(self, directive):
        return directive == self._directive

    def handle(self, directive, data):
        if directive != self._directive:
            msg = f'Cannot handle this directive {directive}'
            raise ValueError(msg)
        defaults = self._context.defaults().get(self._directive, {})
        entries = self._normalize_entries(data, defaults)
        success = True
        for repo, opts in entries:
            if not self._handle_entry(repo, opts):
                success = False
        return success

    @staticmethod
    def _normalize_entries(data, defaults):
        raw = []
        if isinstance(data, dict):
            raw.extend(data.items())
        elif isinstance(data, list):
            for item in data:
                if isinstance(item, dict):
                    raw.extend(item.items())
        entries = []
        for repo, opts in raw:
            merged = dict(defaults)
            if isinstance(opts, dict):
                merged.update(opts)
            elif isinstance(opts, str):
                merged['asset'] = opts
            entries.append((repo, merged))
        return entries

    @staticmethod
    def _arch_tokens(arch_map=None, machine=None):
        raw = (machine or platform.machine()).lower()
        if raw in ('x86_64', 'amd64'):
            uname_m = 'x86_64'
            default_arch = 'x86_64'
            go_arch = 'amd64'
            node_arch = 'x64'
        elif raw in ('aarch64', 'arm64'):
            uname_m = 'aarch64'
            default_arch = 'arm64'
            go_arch = 'arm64'
            node_arch = 'arm64'
        else:
            uname_m = raw
            default_arch = raw
            go_arch = raw
            node_arch = raw
        mapping = arch_map or {}
        arch = mapping.get(uname_m, mapping.get(default_arch, default_arch))
        return {
            'uname_m': uname_m,
            'arch': arch,
            'go_arch': go_arch,
            'node_arch': node_arch,
        }

    @staticmethod
    def _as_list(value):
        if value is None:
            return []
        if isinstance(value, str):
            return [value]
        return list(value)

    @staticmethod
    def _parse_version_tuple(text):
        match = re.search(r'(\d+(?:\.\d+)+)', text or '')
        if not match:
            return None
        return tuple(int(part) for part in match.group(1).split('.'))

    @classmethod
    def _version_satisfies(cls, bin_path, min_version):
        required = cls._parse_version_tuple(str(min_version))
        if required is None:
            return False
        try:
            res = subprocess.run(
                [bin_path, '--version'],
                capture_output=True,
                text=True,
                timeout=5,
                check=False,
            )
        except (OSError, subprocess.SubprocessError):
            return False
        found = cls._parse_version_tuple(f'{res.stdout}\n{res.stderr}')
        if found is None:
            return False
        pad = max(len(found), len(required))
        return found + (0,) * (pad - len(found)) >= required + (0,) * (
            pad - len(required)
        )

    def _is_satisfied(self, bins, bin_dir, creates, min_version):
        if not bins and not creates:
            return False
        for spec in bins:
            name = os.path.basename(spec)
            local_candidate = os.path.join(bin_dir, name)
            if os.path.isfile(local_candidate) and os.access(local_candidate, os.X_OK):
                found = local_candidate
            else:
                found = shutil.which(name)
            if not found:
                return False
            if min_version and not self._version_satisfies(found, min_version):
                return False
        return all(os.path.exists(os.path.expanduser(path)) for path in creates)

    @staticmethod
    def _resolve_latest_tag(repo):
        url = f'https://github.com/{repo}/releases/latest'
        final_url = None
        if shutil.which('curl') is not None:
            res = subprocess.run(
                [
                    'curl',
                    '-fLSs',
                    '--retry',
                    '3',
                    '--retry-delay',
                    '2',
                    '-o',
                    os.devnull,
                    '-w',
                    '%{url_effective}',
                    url,
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            if res.returncode == 0:
                final_url = res.stdout.strip()
        if not final_url:
            req = urllib.request.Request(
                url, headers={'User-Agent': 'dotbot-ghrelease'}
            )
            with urllib.request.urlopen(req, timeout=30) as resp:
                final_url = resp.geturl()
        if not final_url or '/releases/tag/' not in final_url:
            msg = f'Could not resolve latest release tag for {repo} from {final_url!r}'
            raise RuntimeError(msg)
        tag = urllib.parse.unquote(
            final_url.split('/releases/tag/', 1)[1].split('?', 1)[0].strip('/')
        )
        if not tag:
            msg = f'Empty release tag resolved for {repo}'
            raise RuntimeError(msg)
        return tag

    @staticmethod
    def _download(url, dest_path):
        if shutil.which('curl') is not None:
            res = subprocess.run(
                [
                    'curl',
                    '-fLSs',
                    '--retry',
                    '3',
                    '--retry-delay',
                    '2',
                    '-o',
                    dest_path,
                    url,
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            if res.returncode == 0:
                return
            err = res.stderr.strip() or f'curl exited with {res.returncode}'
            raise RuntimeError(f'Failed to download {url}: {err}')
        req = urllib.request.Request(url, headers={'User-Agent': 'dotbot-ghrelease'})
        try:
            with (
                urllib.request.urlopen(req, timeout=60) as resp,
                open(dest_path, 'wb') as out,
            ):
                shutil.copyfileobj(resp, out)
        except urllib.error.URLError as exc:
            raise RuntimeError(f'Failed to download {url}: {exc}') from exc

    @staticmethod
    def _safe_relpath(raw_name, strip_components=0):
        norm = raw_name.replace('\\', '/')
        if norm.startswith('/'):
            msg = f'Archive entry has absolute path: {raw_name}'
            raise RuntimeError(msg)
        parts = [p for p in norm.split('/') if p not in ('', '.')]
        if '..' in parts:
            msg = f'Archive entry attempts path traversal: {raw_name}'
            raise RuntimeError(msg)
        if len(parts) <= strip_components:
            return None
        return os.path.join(*parts[strip_components:])

    @classmethod
    def _safe_join(cls, root, rel):
        root_real = os.path.realpath(root)
        target = os.path.realpath(os.path.join(root_real, rel))
        if target != root_real and not target.startswith(root_real + os.sep):
            msg = f'Archive target escapes destination: {rel}'
            raise RuntimeError(msg)
        return os.path.join(root_real, rel)

    @classmethod
    def _extract_archive(cls, archive_path, asset_name, stage_dir, strip_components=0):
        lower = asset_name.lower()
        if lower.endswith(('.tar.gz', '.tgz', '.tar.xz', '.txz', '.tar')):
            with tarfile.open(archive_path, mode='r:*') as tf:
                for member in tf.getmembers():
                    rel = cls._safe_relpath(member.name, strip_components)
                    if not rel:
                        continue
                    dest = cls._safe_join(stage_dir, rel)
                    if member.isdir():
                        os.makedirs(dest, exist_ok=True)
                    elif member.isfile():
                        os.makedirs(os.path.dirname(dest), exist_ok=True)
                        src = tf.extractfile(member)
                        if src is None:
                            continue
                        with src, open(dest, 'wb') as out:
                            shutil.copyfileobj(src, out)
                        mode = member.mode & 0o777
                        if mode:
                            os.chmod(dest, mode)
                    elif member.issym():
                        link_target = member.linkname
                        if os.path.isabs(link_target):
                            msg = f'Archive symlink points to absolute path: {link_target}'
                            raise RuntimeError(msg)
                        resolved = os.path.realpath(
                            os.path.join(os.path.dirname(dest), link_target)
                        )
                        stage_real = os.path.realpath(stage_dir)
                        if resolved != stage_real and not resolved.startswith(
                            stage_real + os.sep
                        ):
                            msg = f'Archive symlink escapes staging dir: {link_target}'
                            raise RuntimeError(msg)
                        os.makedirs(os.path.dirname(dest), exist_ok=True)
                        if os.path.lexists(dest):
                            os.unlink(dest)
                        os.symlink(link_target, dest)
            return

        if lower.endswith('.zip'):
            with zipfile.ZipFile(archive_path) as zf:
                for info in zf.infolist():
                    is_dir = info.is_dir()
                    rel = cls._safe_relpath(info.filename, strip_components)
                    if not rel:
                        continue
                    dest = cls._safe_join(stage_dir, rel)
                    if is_dir:
                        os.makedirs(dest, exist_ok=True)
                        continue
                    os.makedirs(os.path.dirname(dest), exist_ok=True)
                    with zf.open(info) as src, open(dest, 'wb') as out:
                        shutil.copyfileobj(src, out)
                    unix_mode = (info.external_attr >> 16) & 0o777
                    if unix_mode:
                        os.chmod(dest, unix_mode)
            return

        if lower.endswith('.gz'):
            out_name = os.path.basename(asset_name[:-3]) or 'binary'
            dest = cls._safe_join(stage_dir, out_name)
            with gzip.open(archive_path, 'rb') as src, open(dest, 'wb') as out:
                shutil.copyfileobj(src, out)
            return

        dest = cls._safe_join(stage_dir, os.path.basename(asset_name))
        shutil.copy2(archive_path, dest)

    @staticmethod
    def _find_in_tree(root, spec):
        direct = os.path.join(root, spec)
        if os.path.isfile(direct):
            return direct
        target_name = os.path.basename(spec)
        candidates = []
        for dirpath, _, filenames in os.walk(root):
            for fname in filenames:
                if fname == target_name:
                    candidates.append(os.path.join(dirpath, fname))
        if candidates:
            candidates.sort(key=lambda p: (len(p.split(os.sep)), p))
            return candidates[0]
        all_files = []
        for dirpath, _, filenames in os.walk(root):
            for fname in filenames:
                all_files.append(os.path.join(dirpath, fname))
        if len(all_files) == 1:
            return all_files[0]
        return None

    @staticmethod
    def _install_executable(src_path, dest_path):
        os.makedirs(os.path.dirname(dest_path), exist_ok=True)
        tmp_dest = f'{dest_path}.tmp.{os.getpid()}'
        shutil.copy2(src_path, tmp_dest)
        mode = stat.S_IMODE(os.stat(tmp_dest).st_mode)
        os.chmod(
            tmp_dest,
            mode
            | stat.S_IRWXU
            | stat.S_IRGRP
            | stat.S_IXGRP
            | stat.S_IROTH
            | stat.S_IXOTH,
        )
        os.replace(tmp_dest, dest_path)

    @staticmethod
    def _atomic_symlink(target, link_path):
        os.makedirs(os.path.dirname(link_path), exist_ok=True)
        tmp_link = f'{link_path}.tmp.{os.getpid()}'
        if os.path.lexists(tmp_link):
            os.unlink(tmp_link)
        os.symlink(target, tmp_link)
        os.replace(tmp_link, link_path)

    def _handle_entry(self, repo, opts):
        asset_tmpl = opts.get('asset')
        if not asset_tmpl:
            self._log.error(f'ghrelease entry {repo} is missing required key "asset"')
            return False

        bin_dir = os.path.expanduser(opts.get('bin_dir', '~/.local/bin'))
        bins = self._as_list(opts.get('bins'))
        creates = self._as_list(opts.get('creates'))
        extract_to_raw = opts.get('extract_to')
        extract_to = os.path.expanduser(extract_to_raw) if extract_to_raw else None
        strip_components = int(opts.get('strip_components', 0))
        min_version = opts.get('min_version')
        post_install = self._as_list(opts.get('post_install'))
        pinned_tag = opts.get('tag')

        if self._is_satisfied(bins, bin_dir, creates, min_version):
            self._log.info(f'{repo} already installed')
            return True

        tokens = self._arch_tokens(opts.get('arch_map'))
        needs_tag = '{tag}' in asset_tmpl or '{version}' in asset_tmpl

        if self._context.dry_run():
            preview_tokens = dict(
                tokens,
                tag=pinned_tag or '<latest>',
                version=(pinned_tag or '<latest>').removeprefix('v'),
            )
            preview_asset = asset_tmpl.format(**preview_tokens)
            self._log.action(f'Would install {repo} ({preview_asset})')
            return True

        try:
            tag = pinned_tag
            if tag is None and needs_tag:
                tag = self._resolve_latest_tag(repo)
            fmt_tokens = dict(tokens)
            if tag is not None:
                fmt_tokens['tag'] = tag
                fmt_tokens['version'] = tag.removeprefix('v')
            asset_name = asset_tmpl.format(**fmt_tokens)
            if tag is not None:
                url = f'https://github.com/{repo}/releases/download/{urllib.parse.quote(tag, safe="")}/{asset_name}'
            else:
                url = f'https://github.com/{repo}/releases/latest/download/{asset_name}'

            self._log.action(f'Installing {repo} ({asset_name})')
            with tempfile.TemporaryDirectory(prefix='ghrelease-') as tmpdir:
                archive_path = os.path.join(tmpdir, asset_name)
                stage_dir = os.path.join(tmpdir, 'stage')
                os.makedirs(stage_dir, exist_ok=True)

                self._download(url, archive_path)
                self._extract_archive(
                    archive_path,
                    asset_name,
                    stage_dir,
                    strip_components=strip_components,
                )

                if extract_to:
                    os.makedirs(
                        os.path.dirname(os.path.abspath(extract_to)), exist_ok=True
                    )
                    if os.path.islink(extract_to) or os.path.isfile(extract_to):
                        os.unlink(extract_to)
                    elif os.path.isdir(extract_to):
                        shutil.rmtree(extract_to)
                    shutil.move(stage_dir, extract_to)
                    for spec in bins:
                        src = self._find_in_tree(extract_to, spec)
                        if src is None:
                            msg = f'Could not find binary {spec!r} under {extract_to}'
                            raise RuntimeError(msg)
                        mode = stat.S_IMODE(os.stat(src).st_mode)
                        if not (mode & stat.S_IXUSR):
                            os.chmod(src, mode | 0o755)
                        dest = os.path.join(bin_dir, os.path.basename(spec))
                        self._atomic_symlink(src, dest)
                else:
                    for spec in bins:
                        src = self._find_in_tree(stage_dir, spec)
                        if src is None:
                            msg = f'Could not find binary {spec!r} inside {asset_name}'
                            raise RuntimeError(msg)
                        dest = os.path.join(bin_dir, os.path.basename(spec))
                        self._install_executable(src, dest)

            for cmd in post_install:
                stdout = subprocess.DEVNULL if self._sup_stdout else None
                stderr = subprocess.DEVNULL if self._sup_stderr else None
                if (
                    subprocess.call(
                        cmd,
                        shell=True,
                        stdout=stdout,
                        stderr=stderr,
                        cwd=self._context.base_directory(),
                    )
                    != 0
                ):
                    self._log.error(f'post_install command failed for {repo}: {cmd}')
                    return False
        except (
            OSError,
            RuntimeError,
            KeyError,
            tarfile.TarError,
            zipfile.BadZipFile,
        ) as exc:
            self._log.error(f'Failed to install {repo}: {exc}')
            return False

        return True
