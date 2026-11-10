# Shared recursive submodule verification helper

_submodules_missing() {
  local base="$1" gm path sub_dir
  gm="${base}/.gitmodules"
  [[ -f "${gm}" ]] || return 1
  while IFS= read -r path; do
    [[ -n "${path}" ]] || continue
    sub_dir="${base}/${path}"
    if [[ ! -e "${sub_dir}/.git" ]] || _submodules_missing "${sub_dir}"; then
      return 0
    fi
  done < <(git -C "${base}" config --file .gitmodules --get-regexp '^submodule\..*\.path$' | awk '{print $2}')
  return 1
}

ensure_submodules() {
  local repo="${1:?repo path required}"
  [[ -e "${repo}/.git" ]] || return 0
  if _submodules_missing "${repo}"; then
    # Pin the files ref backend: reftable (default on newer/vendor git) breaks
    # gitoxide (Starship), libgit2 and lazy.nvim's .git/HEAD reader.
    git -C "${repo}" -c init.defaultRefFormat=files submodule update --init --recursive
  fi
}
