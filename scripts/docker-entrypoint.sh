#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  set -- zsh
fi

target_user="dotuser"

# Plain non-root invocations (`docker run [-it] --rm dotfiles:ubuntu ...`) take the zero-cost path.
if [[ "$(id -u)" != "0" ]]; then
  exec "$@"
fi

target_uid="$(id -u "${target_user}")"
target_gid="$(id -g "${target_user}")"
want_uid="${HOST_UID:-${target_uid}}"
want_gid="${HOST_GID:-${target_gid}}"

if [[ "${want_gid}" != "${target_gid}" ]]; then
  if getent group "${want_gid}" >/dev/null 2>&1; then
    usermod -g "${want_gid}" "${target_user}"
  else
    groupmod -o -g "${want_gid}" "${target_user}"
  fi
fi

if [[ "${want_uid}" != "${target_uid}" ]]; then
  usermod -o -u "${want_uid}" "${target_user}"
  rm -f /var/log/lastlog /var/log/faillog
fi

if [[ "${want_uid}" != "${target_uid}" || "${want_gid}" != "${target_gid}" ]]; then
  chown -hR "${want_uid}:${want_gid}" "/home/${target_user}"
fi

if [[ -S /var/run/docker.sock ]]; then
  sock_gid="$(stat -c '%g' /var/run/docker.sock 2>/dev/null || true)"
  if [[ -n "${sock_gid}" && "${sock_gid}" != "0" ]] && ! id -G "${target_user}" | tr ' ' '\n' | grep -qx "${sock_gid}"; then
    sock_grp="$(getent group "${sock_gid}" | cut -d: -f1 || true)"
    if [[ -z "${sock_grp}" ]]; then
      sock_grp="hostdocker"
      groupadd -o -g "${sock_gid}" "${sock_grp}"
    fi
    usermod -aG "${sock_grp}" "${target_user}"
  fi
fi

if [[ -S /run/gpg-agent.extra.sock ]]; then
  gnupg_dir="/home/${target_user}/.gnupg"
  mkdir -p "${gnupg_dir}"
  chmod 0700 "${gnupg_dir}"
  ln -sfn /run/gpg-agent.extra.sock "${gnupg_dir}/S.gpg-agent"
  chown -h "${want_uid}:${want_gid}" "${gnupg_dir}" "${gnupg_dir}/S.gpg-agent"
fi

export HOME="/home/${target_user}"
export USER="${target_user}"
export LOGNAME="${target_user}"
unset HOST_UID HOST_GID

exec setpriv --reuid="${want_uid}" --regid="${want_gid}" --init-groups -- "$@"
