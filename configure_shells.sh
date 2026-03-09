#!/bin/sh
# =============================================================================
# configure_shells.sh — Install or symlink shell prompt configurations
# =============================================================================
#
# Usage:
#   ./configure_shells.sh [OPTIONS]
#   curl -fsSL <url> | sh
#   curl -fsSL <url> | sh -s -- [OPTIONS]
#
# Options:
#   -d DIR      Install directory (default: $HOME)
#   -m METHOD   "copy" or "symlink" (default: copy)
#   -s SHELL    "bash", "zsh", or "all" (default: all)
#   -f          Force — clobber existing files without backup
#   -n          Dry run — show what would happen without doing it
#   -h          Show this help message
#
# Notes:
#   - When -d is specified, method is always "copy" and backup is always on.
#   - When piped from curl (no TTY), files are fetched from GitHub.
#   - Symlink mode requires files in the current working directory.
#
# =============================================================================

set -eu

# ------ ( CONSTANTS ) ---------------------------------------------------------

REPO_BASE="https://raw.githubusercontent.com/mjhika/dot-files/refs/heads/main"

BASH_FILES=".bashrc .bash_prompt"
ZSH_FILES=".zshrc .zsh_prompt"

# ------- ( DEFAULTS ) ---------------------------------------------------------

INSTALL_DIR="$HOME"
METHOD="copy"
SHELL_TARGET="all"
FORCE=0
DRY_RUN=0
CUSTOM_DIR=0

# ------- ( HELPERS ) ----------------------------------------------------------

info()  { printf "  \033[1;34m::\033[0m %s\n" "$1"; }
warn()  { printf "  \033[1;33m::\033[0m %s\n" "$1"; }
err()   { printf "  \033[1;31m::\033[0m %s\n" "$1" >&2; }
ok()    { printf "  \033[1;32m::\033[0m %s\n" "$1"; }

usage() {
    sed -n '/^# Usage:/,/^# ====/{/^# ====/d;s/^# \{0,1\}//;p}' "$0"
    exit 0
}

is_piped() { ! [ -t 0 ]; }

timestamp() { date +%Y%m%d_%H%M%S; }

# ------- ( RESOLVE FILE LIST FOR A GIVEN SHELL ) ------------------------------

files_for_shell() {
    case "$1" in
        bash) echo "$BASH_FILES" ;;
        zsh)  echo "$ZSH_FILES" ;;
        all)  echo "$BASH_FILES $ZSH_FILES" ;;
    esac
}

# ------- ( FETCH A FILE: LOCAL cwd OR REMOTE ) --------------------------------

fetch_file() {
    _file="$1"
    _dest="$2"

    if [ -f "./${_file}" ] && ! is_piped; then
        # Local copy from CWD
        if [ "$DRY_RUN" -eq 1 ]; then
            info "[dry-run] copy ./${_file} -> ${_dest}"
        else
            cp "./${_file}" "${_dest}"
            ok "copied ./${_file} -> ${_dest}"
        fi
    else
        # Remote fetch from GitHub
        _url="${REPO_BASE}/${_file}"
        if [ "$DRY_RUN" -eq 1 ]; then
            info "[dry-run] fetch ${_url} -> ${_dest}"
        else
            if command -v curl >/dev/null 2>&1; then
                curl -fsSL "${_url}" -o "${_dest}"
            elif command -v wget >/dev/null 2>&1; then
                wget -qO "${_dest}" "${_url}"
            else
                err "neither curl nor wget found — cannot fetch ${_file}"
                return 1
            fi
            ok "fetched ${_url} -> ${_dest}"
        fi
    fi
}

# ------- ( SYMLINK A FILE FROM CWD ) ------------------------------------------

link_file() {
    _file="$1"
    _dest="$2"
    _source="$(cd . && pwd)/${_file}"

    if [ ! -f "${_source}" ]; then
        err "${_source} not found — cannot symlink"
        return 1
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        info "[dry-run] symlink ${_source} -> ${_dest}"
    else
        ln -sf "${_source}" "${_dest}"
        ok "symlinked ${_source} -> ${_dest}"
    fi
}

# ------- ( BACKUP A FILE ) ----------------------------------------------------

backup_file() {
    _file="$1"

    if [ ! -e "${_file}" ]; then
        return 0
    fi

    _backup="${_file}.bak.$(timestamp)"

    if [ "$DRY_RUN" -eq 1 ]; then
        info "[dry-run] backup ${_file} -> ${_backup}"
    else
        cp "${_file}" "${_backup}"
        ok "backed up ${_file} -> ${_backup}"
    fi
}

# ------- ( FORCE MODE ) -------------------------------------------------------

remove_file() {
    _file="$1"

    if [ ! -e "${_file}" ]; then
        return 0
    fi

    # Never clobber history files
    case "${_file}" in
        *bash_history|*zsh_history|*histfile) 
            warn "skipping removal of history file ${_file}"
            return 0
            ;;
    esac

    if [ "$DRY_RUN" -eq 1 ]; then
        info "[dry-run] remove ${_file}"
    else
        rm -f "${_file}"
        ok "removed ${_file}"
    fi
}

# ------- ( PARSE ARGS ) -------------------------------------------------------

while getopts "d:m:s:fnh" opt; do
    case "$opt" in
        d)
            INSTALL_DIR="$OPTARG"
            CUSTOM_DIR=1
            ;;
        m)
            case "$OPTARG" in
                copy|symlink) METHOD="$OPTARG" ;;
                *) err "invalid method: $OPTARG (use 'copy' or 'symlink')"; exit 1 ;;
            esac
            ;;
        s)
            case "$OPTARG" in
                bash|zsh|all) SHELL_TARGET="$OPTARG" ;;
                *) err "invalid shell: $OPTARG (use 'bash', 'zsh', or 'all')"; exit 1 ;;
            esac
            ;;
        f) FORCE=1 ;;
        n) DRY_RUN=1 ;;
        h) usage ;;
        ?) exit 1 ;;
    esac
done

# ------- ( ENFORCE CONSTRAINTS ) ----------------------------------------------

# Custom directory always uses copy + backup
if [ "$CUSTOM_DIR" -eq 1 ]; then
    if [ "$METHOD" = "symlink" ]; then
        warn "-d specified — overriding method to 'copy'"
    fi
    METHOD="copy"

    if [ "$FORCE" -eq 1 ]; then
        warn "-d specified — overriding force mode, backups will be made"
    fi
    FORCE=0
fi

# ------- ( SUMMARY ) ----------------------------------------------------------

info "install directory : ${INSTALL_DIR}"
info "method            : ${METHOD}"
info "shell             : ${SHELL_TARGET}"
if [ "$FORCE" -eq 1 ]; then
    info "backup            : off (force)"
else
    info "backup            : on"
fi
if [ "$DRY_RUN" -eq 1 ]; then
    warn "dry run — no changes will be made"
fi
echo ""

# ------- ( CREATE INSTALL DIRECTORY IF NEEDED ) -------------------------------

if [ ! -d "${INSTALL_DIR}" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
        info "[dry-run] mkdir -p ${INSTALL_DIR}"
    else
        mkdir -p "${INSTALL_DIR}"
        ok "created ${INSTALL_DIR}"
    fi
fi

# ------- ( INSTALL ) ----------------------------------------------------------

for file in $(files_for_shell "$SHELL_TARGET"); do
    dest="${INSTALL_DIR}/${file}"

    # Handle existing file
    if [ -e "${dest}" ] || [ -L "${dest}" ]; then
        if [ "$FORCE" -eq 1 ]; then
            remove_file "${dest}"
        else
            backup_file "${dest}"
        fi
    fi

    # Install the file
    case "$METHOD" in
        copy)    fetch_file "${file}" "${dest}" ;;
        symlink) link_file  "${file}" "${dest}" ;;
    esac
done

echo ""
ok "done"
