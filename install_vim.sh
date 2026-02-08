#!/bin/bash

# --- Configuration ---
#
VIMRC_URL="https://raw.githubusercontent.com/mjhika/dot-files/refs/heads/main/.vimrc"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/vim_backups_$TIMESTAMP"

# --- Colors for formatting ---
#
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Vim configuration installation...${NC}"

# --- Deps check ---
#
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
else
    echo -e "${RED}Error: Neither curl nor wget found. Please install one to continue.${NC}"
    exit 1
fi

# --- Backup existing conf files ---
#
if [ -f "$HOME/.vimrc" ] || [ -d "$HOME/.vim" ]; then
    echo -e "${YELLOW}Existing Vim configuration found. Creating backup...${NC}"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$HOME/.vimrc" ]; then
        mv "$HOME/.vimrc" "$BACKUP_DIR/.vimrc"
        echo "  - Moved ~/.vimrc to $BACKUP_DIR/.vimrc"
    fi

    if [ -d "$HOME/.vim" ]; then
        mv "$HOME/.vim" "$BACKUP_DIR/.vim"
        echo "  - Moved ~/.vim folder to $BACKUP_DIR/.vim"
    fi
fi

# --- Install conf files ---
#
echo "Setting up new ~/.vim directory..."
mkdir -p "$HOME/.vim/undodir"

echo -e "Downloading config from GitHub using ${GREEN}$DOWNLOADER${NC}..."

if [ "$DOWNLOADER" = "curl" ]; then
    curl -fLo "$HOME/.vimrc" "$VIMRC_URL"
else
    wget -O "$HOME/.vimrc" "$VIMRC_URL"
fi

# --- Verify install ---
#
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Success! Vim is now configured.${NC}"
    echo "Backups (if any) are located in: $BACKUP_DIR"
else
    echo -e "${RED}Download failed. Please check your internet connection or the URL.${NC}"
    # Restore backup if download failed
    if [ -d "$BACKUP_DIR" ]; then
        echo "Restoring backups..."
        [ -f "$BACKUP_DIR/.vimrc" ] && mv "$BACKUP_DIR/.vimrc" "$HOME/"
        [ -d "$BACKUP_DIR/.vim" ] && mv "$BACKUP_DIR/.vim" "$HOME/"
    fi
    exit 1
fi
