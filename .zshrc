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
fi

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export EDITOR="vim"

HISTFILE="$XDG_DATA_HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# ------- ( CUSTOM PROMPT ) ----------------------------------------------------

if [[ -f ~/.zsh_prompt ]] then;
  source ~/.zsh_prompt
else
  PROMPT="(%n@%m) (%~) λ "
fi

# ------- ( UX CONFIG ) --------------------------------------------------------

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
alias vim="$(where nvim | grep / | tail -n 1)"
alias vi="$(where vim | grep / | tail -n 1)"

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

# activate mise
eval "$(mise activate zsh)"
