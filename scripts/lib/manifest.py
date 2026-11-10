#!/usr/bin/env python3
"""Auto-construct dotfiles symlink, template, directory, submodule, and local-hook manifests."""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import shutil
import stat
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parent.parent.parent


def _bootstrap_vendor(repo_root: Path) -> None:
    vendor_paths = (
        repo_root / 'installer/dotbot/lib/pyyaml/lib',
        repo_root / 'installer/dotbot/src',
        repo_root / 'installer/plugins/dotbot-ifplatform',
    )
    for path in reversed(vendor_paths):
        path_str = str(path)
        if path.is_dir() and path_str not in sys.path:
            sys.path.insert(0, path_str)


_bootstrap_vendor(REPO_ROOT)

import ifplatform
import yaml

_ALL_TARGETS = set(ifplatform.IfPlatform._distros)
_BSD_TARGETS = set(ifplatform.IfPlatform._bsd_distros)
_LINUX_TARGETS = set(ifplatform.IfPlatform._linux_distros)
_OTHER_OS = set(ifplatform.IfPlatform._os_targets) | _BSD_TARGETS

_LOCAL_HOOK_RE = re.compile(
    r'(?:~|\$\{?HOME\}?)/([A-Za-z0-9_./-]+\.local(?:\.[A-Za-z0-9_-]+)?)(?![/A-Za-z0-9_-])'
)
_SUBMODULE_PATH_RE = re.compile(r'^\s*path\s*=\s*(.+?)\s*$', re.MULTILINE)

CLI_TOOLS = (
    'git',
    'zsh',
    'bash',
    'tmux',
    'nvim',
    'rg',
    'fd',
    'fdfind',
    'fzf',
    'starship',
    'zoxide',
    'uv',
    'yazi',
    'lazygit',
    'tree-sitter',
    'tldr',
    'vale',
)


@dataclass(frozen=True)
class PlatformContext:
    did: str
    like_ids: tuple[str, ...] = ()
    is_linux: bool = False
    is_bsd: bool = False
    is_wsl: bool = False

    @classmethod
    def from_host(cls) -> PlatformContext:
        if sys.platform == 'darwin':
            did, like_ids = 'macos', []
        elif os.name == 'nt' or sys.platform in ('win32', 'cygwin', 'msys'):
            did, like_ids = 'windows', []
        elif getattr(ifplatform, 'distro', None) is not None:
            did = ifplatform.distro.id()
            like_ids = ifplatform.distro.like().split()
        else:
            did, raw_likes = ifplatform._stdlib_distro_info()
            like_ids = list(raw_likes)

        if did == 'darwin':
            did = 'macos'
        elif did in ('windows', 'win32', 'nt') or did.startswith(
            ('msys', 'mingw', 'cygwin')
        ):
            did = 'windows'

        all_ids = [did, *like_ids] if did else list(like_ids)
        is_linux = any(d in _LINUX_TARGETS for d in all_ids) or (
            did not in _OTHER_OS and sys.platform.startswith('linux')
        )
        is_bsd = any(d in _BSD_TARGETS for d in all_ids)
        is_wsl = bool(ifplatform._is_wsl(is_linux))
        return cls(
            did=did,
            like_ids=tuple(like_ids),
            is_linux=is_linux,
            is_bsd=is_bsd,
            is_wsl=is_wsl,
        )

    @classmethod
    def for_profile(cls, profile: str) -> PlatformContext:
        if profile == 'macos':
            return cls(did='macos')
        if profile in ('ubuntu', 'ubuntu-minimal'):
            return cls(did='ubuntu', like_ids=('debian',), is_linux=True)
        if profile in ('archlinux', 'archlinux-minimal'):
            return cls(did='arch', is_linux=True)
        return cls.from_host()


@dataclass(frozen=True)
class ProfileManifest:
    profile: str
    modules: tuple[str, ...]
    symlinks: dict[str, str]
    excluded_symlinks: tuple[str, ...]
    templates: dict[str, str]
    generated_files: tuple[str, ...]
    directories: dict[str, int | None]


def matches_platform(directive: str, ctx: PlatformContext) -> bool | None:
    if directive.startswith('ifnot'):
        target, negate = directive[5:], True
    elif directive.startswith('if'):
        target, negate = directive[2:], False
    else:
        return None

    if target not in _ALL_TARGETS:
        return None

    all_ids = [ctx.did, *ctx.like_ids] if ctx.did else list(ctx.like_ids)
    if 'amzn' in all_ids and 'amazon' not in all_ids:
        all_ids.append('amazon')
    elif 'amazon' in all_ids and 'amzn' not in all_ids:
        all_ids.append('amzn')

    matched = (
        target == 'any'
        or (target == 'anylinux' and ctx.is_linux)
        or (target == 'anybsd' and ctx.is_bsd)
        or (target == 'wsl' and ctx.is_wsl)
        or (target in all_ids)
    )
    return (not matched) if negate else matched


def detect_host_profile(
    repo_root: Path = REPO_ROOT,
    home: Path | None = None,
    platform_ctx: PlatformContext | None = None,
) -> str:
    ctx = platform_ctx or PlatformContext.from_host()
    resolved_home = home or Path.home()
    all_ids = {ctx.did, *ctx.like_ids}
    if ctx.did == 'macos':
        return 'macos'
    if 'arch' in all_ids:
        return 'archlinux-minimal'
    if 'ubuntu' in all_ids or 'debian' in all_ids:
        desktop_markers = (
            resolved_home / '.config/i3/config',
            resolved_home / '.config/kitty/kitty.conf',
        )
        if (
            any(m.is_symlink() or m.exists() for m in desktop_markers)
            and (repo_root / 'meta/profiles/ubuntu').is_file()
        ):
            return 'ubuntu'
        return 'ubuntu-minimal'
    return 'ubuntu-minimal'


def load_profile_modules(repo_root: Path, profile: str) -> tuple[str, ...]:
    profile_path = repo_root / 'meta/profiles' / profile
    if not profile_path.is_file():
        raise FileNotFoundError(f"Profile '{profile}' not found at {profile_path}")

    seen: list[str] = ['base']
    for raw_line in profile_path.read_text(encoding='utf-8').splitlines():
        line = raw_line.split('#', 1)[0].strip()
        if line and line not in seen:
            seen.append(line)
    return tuple(seen)


def _normalize_home_rel(raw_dest: str, home: Path | None = None) -> str | None:
    cleaned = raw_dest.strip().rstrip('/')
    if cleaned == '~':
        return ''
    if cleaned.startswith('~/'):
        return cleaned[2:]
    home_str = str(home or Path.home()).rstrip('/')
    if cleaned == home_str:
        return ''
    if cleaned.startswith(home_str + '/'):
        return cleaned[len(home_str) + 1 :]
    return None


def _glob_repo_paths(repo_root: Path, pattern: str) -> list[str]:
    found = [
        os.path.normpath(p)
        for p in glob.glob(pattern, root_dir=repo_root, recursive=True)
    ]
    if '**' in pattern and not pattern.endswith(os.sep):
        found = [f for f in found if (repo_root / f).is_file()]
    return found


def _expand_link_entries(
    repo_root: Path,
    links: dict[str, Any],
    defaults: dict[str, Any],
    home: Path | None = None,
) -> list[tuple[str, str]]:
    expanded: list[tuple[str, str]] = []
    for raw_dest, target in links.items():
        dest_rel = _normalize_home_rel(str(raw_dest), home=home)
        if dest_rel is None:
            continue

        use_glob = bool(defaults.get('glob', False))
        base_prefix = str(defaults.get('prefix', '') or '')
        exclude_paths = list(defaults.get('exclude', []) or [])
        if isinstance(target, dict):
            use_glob = bool(target.get('glob', use_glob))
            base_prefix = str(target.get('prefix', base_prefix) or '')
            exclude_paths = list(target.get('exclude', exclude_paths) or [])
            raw_src = target.get('path')
        else:
            raw_src = target

        if raw_src is None:
            basename = os.path.basename(dest_rel)
            src_pattern = basename.removeprefix('.')
        else:
            src_pattern = os.path.normpath(str(raw_src))

        if use_glob and any(ch in src_pattern for ch in '?*['):
            included = _glob_repo_paths(repo_root, src_pattern)
            excluded: set[str] = set()
            for expat in exclude_paths:
                excluded.update(_glob_repo_paths(repo_root, str(expat)))
            for match in sorted(set(included) - excluded):
                common_dir = os.path.dirname(os.path.commonprefix([src_pattern, match]))
                rel_item = match if not common_dir else match[len(common_dir) + 1 :]
                item_name = f'{base_prefix}{rel_item}'
                full_dest = f'{dest_rel}/{item_name}' if dest_rel else item_name
                expanded.append((full_dest, match))
        else:
            expanded.append((dest_rel, src_pattern))
    return expanded


def resolve_manifest(
    repo_root: Path = REPO_ROOT,
    profile: str | None = None,
    home: Path | None = None,
    platform_ctx: PlatformContext | None = None,
) -> ProfileManifest:
    resolved_profile = profile or detect_host_profile(
        repo_root=repo_root, home=home, platform_ctx=platform_ctx
    )
    ctx = platform_ctx or PlatformContext.for_profile(resolved_profile)
    modules = load_profile_modules(repo_root, resolved_profile)

    link_defaults: dict[str, Any] = {}
    symlinks: dict[str, str] = {}
    inactive_symlinks: list[str] = []
    templates: dict[str, str] = {}
    directories: dict[str, int | None] = {}

    def walk_tasks(tasks: Any, active: bool) -> None:
        if not isinstance(tasks, list):
            return
        for item in tasks:
            if not isinstance(item, dict):
                continue
            for directive, data in item.items():
                plat_match = matches_platform(directive, ctx)
                if plat_match is not None:
                    walk_tasks(data, active and plat_match)
                    continue

                if directive == 'defaults' and active and isinstance(data, dict):
                    if isinstance(data.get('link'), dict):
                        link_defaults.update(data['link'])
                elif directive == 'link' and isinstance(data, dict):
                    entries = _expand_link_entries(
                        repo_root, data, link_defaults, home=home
                    )
                    if active:
                        for dest_rel, src_rel in entries:
                            symlinks[dest_rel] = src_rel
                    else:
                        for dest_rel, _ in entries:
                            if dest_rel not in inactive_symlinks:
                                inactive_symlinks.append(dest_rel)
                elif directive == 'template' and active and isinstance(data, dict):
                    for raw_dest, spec in data.items():
                        dest_rel = _normalize_home_rel(str(raw_dest), home=home)
                        if dest_rel is None:
                            continue
                        src_file = (
                            str(spec.get('source_file', ''))
                            if isinstance(spec, dict)
                            else str(spec or '')
                        )
                        templates[dest_rel] = src_file
                elif directive == 'create' and active:
                    if isinstance(data, list):
                        for raw_dir in data:
                            dir_rel = _normalize_home_rel(str(raw_dir), home=home)
                            if dir_rel is not None:
                                directories.setdefault(dir_rel, None)
                    elif isinstance(data, dict):
                        for raw_dir, opts in data.items():
                            dir_rel = _normalize_home_rel(str(raw_dir), home=home)
                            if dir_rel is None:
                                continue
                            mode: int | None = None
                            if isinstance(opts, dict) and opts.get('mode') is not None:
                                raw_mode = opts['mode']
                                mode = (
                                    int(raw_mode, 8)
                                    if isinstance(raw_mode, str)
                                    else int(raw_mode)
                                )
                            directories[dir_rel] = mode

    for mod in modules:
        cfg_path = repo_root / 'meta/config' / f'{mod}.yaml'
        if not cfg_path.is_file():
            raise FileNotFoundError(
                f"Module configuration '{mod}' not found at {cfg_path}"
            )
        parsed = yaml.safe_load(cfg_path.read_text(encoding='utf-8')) or []
        walk_tasks(parsed, active=True)

    excluded_symlinks = tuple(p for p in inactive_symlinks if p not in symlinks)
    generated_files = ('.global_gitignore',) if 'git' in modules else ()

    return ProfileManifest(
        profile=resolved_profile,
        modules=modules,
        symlinks=symlinks,
        excluded_symlinks=excluded_symlinks,
        templates=templates,
        generated_files=generated_files,
        directories=directories,
    )


def discover_submodules(repo_root: Path = REPO_ROOT) -> list[tuple[str, bool]]:
    if (repo_root / '.git').exists() and shutil.which('git'):
        proc = subprocess.run(
            ['git', '-C', str(repo_root), 'submodule', 'status', '--recursive'],
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode == 0 and proc.stdout.strip():
            results: list[tuple[str, bool]] = []
            for line in proc.stdout.splitlines():
                if not line.strip():
                    continue
                status_char = line[0]
                parts = line[1:].strip().split()
                if len(parts) < 2:
                    continue
                sub_path = parts[1]
                initialized = (
                    status_char != '-' and (repo_root / sub_path / '.git').exists()
                )
                results.append((sub_path, initialized))
            return results

    found: list[tuple[str, bool]] = []

    def walk_gitmodules(base: Path, prefix: Path = Path()) -> None:
        gm = base / '.gitmodules'
        if not gm.is_file():
            return
        text = gm.read_text(encoding='utf-8', errors='ignore')
        for match in _SUBMODULE_PATH_RE.finditer(text):
            sub_rel = Path(match.group(1).strip())
            full_rel = prefix / sub_rel
            sub_dir = base / sub_rel
            initialized = (sub_dir / '.git').exists()
            found.append((full_rel.as_posix(), initialized))
            if initialized:
                walk_gitmodules(sub_dir, full_rel)

    walk_gitmodules(repo_root)
    return found


def discover_local_hooks(
    repo_root: Path = REPO_ROOT, manifest: ProfileManifest | None = None
) -> tuple[str, ...]:
    resolved = manifest or resolve_manifest(repo_root=repo_root)
    hooks: list[str] = []
    visited: set[Path] = set()

    def scan_path(path: Path) -> None:
        real = path.resolve()
        if real in visited or not path.exists():
            return
        visited.add(real)
        if path.is_dir():
            if (path / '.git').exists():
                return
            for child in sorted(path.iterdir()):
                scan_path(child)
            return
        if path.is_file():
            content = path.read_text(encoding='utf-8', errors='ignore')
            for match in _LOCAL_HOOK_RE.finditer(content):
                rel_hook = match.group(1)
                if rel_hook not in hooks:
                    hooks.append(rel_hook)

    for src_rel in [*resolved.symlinks.values(), *resolved.templates.values()]:
        if src_rel:
            scan_path(repo_root / src_rel)

    return tuple(hooks)


def run_doctor(
    repo_root: Path = REPO_ROOT,
    profile: str | None = None,
    home: Path | None = None,
) -> int:
    resolved_home = home or Path.home()
    ctx = (
        PlatformContext.for_profile(profile) if profile else PlatformContext.from_host()
    )
    manifest = resolve_manifest(
        repo_root=repo_root,
        profile=profile,
        home=resolved_home,
        platform_ctx=ctx,
    )
    submodules = discover_submodules(repo_root=repo_root)
    local_hooks = discover_local_hooks(repo_root=repo_root, manifest=manifest)

    failures = 0
    print(f'==> Dotfiles root: {repo_root} (profile: {manifest.profile})')

    print('==> Managed symlinks, templates & directories:')
    for rel_dest, rel_src in manifest.symlinks.items():
        dest = resolved_home / rel_dest
        if not dest.exists():
            reason = (
                f'broken symlink -> {os.readlink(dest)}'
                if dest.is_symlink()
                else 'missing'
            )
            print(f'  [FAIL] {dest} ({reason})')
            failures += 1
        elif not dest.is_symlink():
            print(f'  [FAIL] {dest} (not a symlink; expected -> {rel_src})')
            failures += 1
        else:
            print(f'  [ok]   {dest}')

    for rel_dest in manifest.templates:
        dest = resolved_home / rel_dest
        if not dest.is_file() or dest.stat().st_size == 0:
            print(f'  [FAIL] {dest} (missing or empty rendered template)')
            failures += 1
            continue
        text = dest.read_text(encoding='utf-8', errors='ignore')
        if '{{' in text or '}}' in text:
            print(f'  [FAIL] {dest} (unrendered template placeholders)')
            failures += 1
        else:
            print(f'  [ok]   {dest}')

    for rel_dest in manifest.generated_files:
        dest = resolved_home / rel_dest
        if not dest.is_file() or dest.stat().st_size == 0:
            print(f'  [FAIL] {dest} (missing or empty generated file)')
            failures += 1
        else:
            print(f'  [ok]   {dest}')

    for rel_dir, expected_mode in manifest.directories.items():
        dpath = resolved_home / rel_dir
        if not dpath.is_dir():
            print(f'  [FAIL] {dpath} (missing directory)')
            failures += 1
            continue
        if expected_mode is not None:
            actual_mode = stat.S_IMODE(dpath.stat().st_mode)
            if actual_mode != expected_mode:
                print(
                    f'  [FAIL] {dpath} (mode {oct(actual_mode)}, expected {oct(expected_mode)})'
                )
                failures += 1
                continue
        print(f'  [ok]   {dpath}')

    print('==> Submodules:')
    for sub_path, initialized in submodules:
        if initialized:
            print(f'  [ok]   {sub_path}')
        else:
            print(f'  [FAIL] {sub_path} (uninitialized)')
            failures += 1

    print('==> CLI tools:')
    for tool in CLI_TOOLS:
        resolved_tool = shutil.which(tool)
        if resolved_tool:
            print(f'  [ok]   {tool:<12} -> {resolved_tool}')
        else:
            print(f'  [skip] {tool:<12} (not installed)')

    print('==> Local override hooks:')
    for rel_hook in local_hooks:
        hook_path = resolved_home / rel_hook
        status = '[present]' if hook_path.exists() else '[absent] '
        print(f'  {status} {hook_path}')

    if failures > 0:
        print(f'==> Doctor found {failures} issue(s)', file=sys.stderr)
        return 1
    print('==> Doctor checks passed')
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description='Dotfiles manifest & health-check helper'
    )
    parser.add_argument(
        'command',
        choices=('doctor', 'dump'),
        default='dump',
        nargs='?',
        help='Action to execute',
    )
    parser.add_argument(
        '--repo', type=Path, default=REPO_ROOT, help='Dotfiles repo root'
    )
    parser.add_argument('-P', '--profile', default=None, help='Target profile name')
    parser.add_argument('--home', type=Path, default=None, help='Target home directory')
    args = parser.parse_args(argv)

    if args.command == 'doctor':
        return run_doctor(repo_root=args.repo, profile=args.profile, home=args.home)

    manifest = resolve_manifest(
        repo_root=args.repo, profile=args.profile, home=args.home
    )
    payload = {
        **asdict(manifest),
        'submodules': [
            {'path': p, 'initialized': ok}
            for p, ok in discover_submodules(repo_root=args.repo)
        ],
        'local_hooks': list(
            discover_local_hooks(repo_root=args.repo, manifest=manifest)
        ),
    }
    print(json.dumps(payload, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
