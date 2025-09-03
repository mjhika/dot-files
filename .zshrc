if ! [[ $(command -v brew help) ]]; then
  [[ -f /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
  [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

add_to_path() {
  local usage="Usage: modify_path [-a|-p] <directory>"
  local action=""
  local dir=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--append)
        action="append"
        shift
        ;;
      -p|--prepend)
        action="prepend"
        shift
        ;;
      -*)
        echo "Error: Unknown opt $1" >&2
        echo "$usage" >&2
        return 1
        ;;
      *)
        if [[ -z "$dir" ]]; then
          dir="$1"
          shift
        else
          echo "Error: Too many args" >&2
          echo "$usage" >&2
          return 1
        fi
        ;;
    esac
  done

  if [[ -z "$action" || -z "$dir" ]]; then
    echo "Error: Missing required" >&2
    echo "$usage" >&2
    return 1
  fi

  dir=$(realpath "$dir")

  if [[ ":$PATH:" == *":$dir:"* ]]; then
    return 0
  fi

  case "$action" in
    append)
      path+=("$dir")
      ;;
    prepend)
      path=("$dir" $path)
      ;;
  esac
  export PATH
}

add_to_path -p $HOME/.local/bin

if [[ $(command -v go) ]]; then
  add_to_path -p $HOME/go/bin
  case "$OSTYPE" in
    linux-gnu) add_to_path -a /usr/local/go/bin ;;
    darwin*)   add_to_path -a /usr/local/go/bin ;;
    freebsd*)  add_to_path -a /usr/local/bin/go ;;
    *)         echo unknown OSTYPE ;;
  esac
fi

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export EDITOR="vim"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"

HISTFILE="$XDG_DATA_HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

#################################################################
# prompt
#################################################################

# https://joshigaurava.medium.com/custom-zsh-prompt-from-scratch-171e55a80f58

COLOR_PROMPT_TEXT='012'
COLOR_PROMPT_GLYPH='008'
NUM_DIRS_LEFT_OF_TRUNCATION=1
NUM_DIRS_RIGHT_OF_TRUNCATION=2
GLYPH_PROMPT_TRUNCATION_SYMBOL='⋯'
GLYPH_PROMPT_END_SYMBOL='❯'

set_prompt() {
  [[ $NUM_DIRS_LEFT_OF_TRUNCATION -le 0 ]] && NUM_DIRS_LEFT_OF_TRUNCATION=1
  [[ $NUM_DIRS_RIGHT_OF_TRUNCATION -le 0 ]] && NUM_DIRS_RIGHT_OF_TRUNCATION=2

  local prompt_truncation_symbol="%F{${COLOR_PROMPT_GLYPH}}%B${GLYPH_PROMPT_TRUNCATION_SYMBOL}%b%f"
  local prompt_end_symbol="%F{${COLOR_PROMPT_GLYPH}}%B${GLYPH_PROMPT_END_SYMBOL}%b%f"
  local total_dirs=$(($NUM_DIRS_LEFT_OF_TRUNCATION+$NUM_DIRS_RIGHT_OF_TRUNCATION+1))
  local dir_path_full="%F{${COLOR_PROMPT_TEXT}}%d%f"
  local dir_path_truncated="%F{${COLOR_PROMPT_TEXT}}%-${NUM_DIRS_LEFT_OF_TRUNCATION}d/%f${prompt_truncation_symbol}%F{${COLOR_PROMPT_TEXT}}/%${NUM_DIRS_RIGHT_OF_TRUNCATION}d%f"

  PROMPT="%(${total_dirs}C.${dir_path_truncated}.${dir_path_full}) ${prompt_end_symbol} "
}

precmd_functions+=(set_prompt)

COLOR_GIT_REPOSITORY_TEXT='007'
COLOR_GIT_BRANCH_TEXT='007'
COLOR_GIT_STATUS_CLEAN='010'
COLOR_GIT_STATUS_DIRTY='009'
GLYPH_GIT_BRANCH_SYNC_SYMBOL='«'
GLYPH_GIT_STASH_SYMBOL='∘'
GLYPH_GIT_STATUS_SYMBOL='»'

set_rprompt() {
  local git_branch_name=$(git symbolic-ref --short HEAD 2> /dev/null)
  if [[ -z $git_branch_name ]]; then
    RPROMPT=""

    return
  fi

  local git_remote_commit=$(git rev-parse "origin/$git_branch_name" 2> /dev/null)
  local git_local_commit=$(git rev-parse "$git_branch_name" 2> /dev/null)
  local git_branch_sync_color=$COLOR_GIT_STATUS_DIRTY
  if [[ $git_remote_commit == $git_local_commit ]]; then
    git_branch_sync_color=$COLOR_GIT_STATUS_CLEAN
  fi

  local git_stash=$(git stash list)
  local git_stash_symbol=$GLYPH_GIT_STASH_SYMBOL
  if [[ -z $git_stash ]]; then
    git_stash_symbol=""
  fi

  local git_status=$(git status --porcelain)
  local git_stash_color=$COLOR_GIT_STATUS_DIRTY
  local git_status_color=$COLOR_GIT_STATUS_DIRTY
  if [[ -z $git_status ]]; then
    git_stash_color=$COLOR_GIT_STATUS_CLEAN
    git_status_color=$COLOR_GIT_STATUS_CLEAN
  fi

  local git_repository_path=$(git rev-parse --show-toplevel)
  local git_repository_name=$(basename "$git_repository_path")

  local git_repository_text="%F{${COLOR_GIT_REPOSITORY_TEXT}}${git_repository_name}%f"
  local git_branch_sync_symbol="%F{${git_branch_sync_color}}%B${GLYPH_GIT_BRANCH_SYNC_SYMBOL}%b%f"
  local git_stash_symbol="%F{${git_stash_color}}%B${git_stash_symbol}%b%f"
  local git_status_symbol="%F{${git_status_color}}%B${GLYPH_GIT_STATUS_SYMBOL}%b%f"
  local git_branch_text="%F{${COLOR_GIT_BRANCH_TEXT}}${git_branch_name}%f"

  RPROMPT="${git_repository_text} ${git_branch_sync_symbol}${git_stash_symbol}${git_status_symbol} ${git_branch_text}"
}

precmd_functions+=(set_rprompt)

#################################################################
# UX config
#################################################################

if [[ $(command -v direnv version) ]]; then
  eval "$(direnv hook zsh)"
fi

if [[ $(command -v go) ]]; then
  export GOBIN="$(go env GOPATH)/bin"
  export GOPRIVATE="github.com/mjhika,github.com/EVIRTSHEALTH"
fi
export BAT_THEME="ansi"
export DOOMDIR="$XDG_CONFIG_HOME/doom"

# because the zsh will set ZLE to vi mode with EDITOR set to vi, vim, nvim then
# to retain the default emacs experience we manually overide bindkey emacs mode
bindkey -e

# Vim alias
alias vim='nvim'
alias vi='nvim'

# alias ls
alias ls='ls --color=auto -hvF'
alias ll='ls -l'
alias la='ls -lA'
alias llinks='ll `find . -maxdepth 1 -type l -print`'

# alias mv
alias mv='mv -i'

# tree common ignores
alias tre="tree -I node_modules -I .cpcache -I .cache -I .git"

# alias for lazygit
alias lg="lazygit"

# aliases for ip addresses
alias ip='ip -c=auto'
alias localip='ifconfig | grep -E "\d+\.\d+\.\d+\.\d+"'
flushDNS() {
  if [[ $(uname) == "Darwin" ]]; then
    sudo killall -HUP mDNSResponder
  fi
  if [[ $(uname) == "Linux" ]]; then
    sudo systemd-resolve --flush-caches
  fi
}

# alias for grep
alias grep='grep --color=auto'

# alias for diff
alias diff='diff --color=auto'

# new tmux session
alias nmux='tmux new -A -s $(basename $(pwd) | tr . _)'

# add fzf shell integration
if [[ $(command -v fzf) ]]; then
  eval "$(fzf --zsh)"
fi

[[ -s "$XDG_DATA_HOME/sdkman/bin/sdkman-init.sh" ]] && source "$XDG_DATA_HOME/sdkman/bin/sdkman-init.sh"
