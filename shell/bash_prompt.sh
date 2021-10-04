#!/usr/bin/env bash

# Set colors {{{

function set_colors() {
  local color_prompt
  case "$TERM" in
    xterm-color|xterm-kitty|*-256color)
      color_prompt=yes
      ;;
    *)
      color_prompt=no
      ;;
  esac

  if [ "$color_prompt" = yes ]; then
    declare RED="\[\033[0;31m\]"
    declare PINK="\[\033[1;31m\]"
    declare YELLOW="\[\033[1;33m\]"
    declare GREEN="\[\033[0;32m\]"
    declare LT_GREEN="\[\033[1;32m\]"
    declare BLUE="\[\033[0;34m\]"
    declare PURPLE="\[\033[1;35m\]"
    declare COLOR_NONE="\[\033[0m\]"
  else
    declare RED=""
    declare PINK=""
    declare YELLOW=""
    declare GREEN=""
    declare LT_GREEN=""
    declare BLUE=""
    declare PURPLE=""
    declare COLOR_NONE=""
  fi
}

set_colors

#}}}

# Parse Git {{{

function parse_git_branch {
  local git_status
  git_status="$(git status 2> /dev/null)"

  # Check if rebasing
  if [[ ! "${git_status}" =~ ^On[[:space:]]branch[[:space:]]([^${IFS}]*) ]]; then
    local toplevel
    toplevel=$(git rev-parse --show-toplevel 2> /dev/null)

    if [[ -z "$toplevel" ]]; then
      return
    fi

    if [[ -d "$toplevel/.git/rebase-merge" || -d "$toplevel/.git/rebase-apply" ]]; then
      echo "${PINK}(rebase in progress"

      local sha_file sha
      sha_file="$toplevel/.git/rebase-merge/stopped-sha"
      if [[ -e "$sha_file" ]]; then
        sha=$(cut -c 1-6 < "${sha_file}")
        echo "${COLOR_NONE}:${sha}${PINK})${COLOR_NONE}"
      else
        echo ")${COLOR_NONE}"
      fi
    fi

    return
  fi

  local branch
  branch=${BASH_REMATCH[1]}

  # Compare with remote
  local remote=""
  if [[ "${git_status}" =~ Your[[:space:]]branch[[:space:]]is[[:space:]]ahead[[:space:]]of ]]; then
    remote="${BLUE}:${LT_GREEN} "
  elif [[ "${git_status}" =~ Your[[:space:]]branch[[:space:]]is[[:space:]]behind ]]; then
    remote="${BLUE}:${LT_GREEN} "
  elif [[ "${git_status}" =~ Your[[:space:]]branch[[:space:]]and[[:space:]](.*)[[:space:]]have[[:space:]]diverged ]]; then
    remote="${BLUE}:${PURPLE} "
  fi

  # Check if dirty
  local git_is_dirty=""
  if [[ ! "${git_status}" =~ working[[:space:]]tree[[:space:]]clean ]]; then
    if [[ -z "$remote" ]]; then
      git_is_dirty="${BLUE}:${RED}"
    else
      git_is_dirty="${RED}"
    fi
  fi

  echo "${YELLOW}($branch$remote$git_is_dirty${YELLOW})${COLOR_NONE}"
}

# }}}

# Set propmpt
function set_prompt {
  export PS1=""
  case "$TERM" in
    xterm*|rxvt*)
      PS1="\[\e]0;\u@\h: \w\a\]"
      ;;
    *)
      ;;
  esac

  PS1+="[${GREEN}\u${COLOR_NONE}@${BLUE}\h${COLOR_NONE}:${PURPLE}\w${COLOR_NONE}]$(parse_git_branch)${COLOR_NONE}\$ "
}

export PROMPT_COMMAND=set_prompt

# vim:foldmethod=marker
