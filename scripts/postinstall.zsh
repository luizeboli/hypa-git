#!/usr/bin/env zsh
##
# Hypa Git ZSH
#
# Author: Luiz Felicio                  
# License: MIT                          
# https://github.com/luizeboli/hypa-git
##

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------

HYPA_GIT_ROOT="$PWD/index.zsh"
HYPA_GIT_DEST="$HOME/.hypa-git"
HYPA_GIT_SYMLINK="/usr/local/bin/hypa-git"

# ------------------------------------------------------------------------------
# Entry Point
# ------------------------------------------------------------------------------

init() {
  echo "Trying to install hypa-git..."

  [[ ! -f "$HYPA_GIT_ROOT" ]] && echo "Unable to find hypa-git root file..." && exit 1

  cd ..
  
  echo "Copying 'hypa-git' directory to '$HYPA_GIT_DEST'..."
  rsync -av --progress "./hypa-git/" "$HYPA_GIT_DEST" --exclude ".git" 1> /dev/null || { echo "Unable to copy hypa-git directory..." && exit 1 }

  if [[ -h "$HYPA_GIT_SYMLINK" ]]; then
    echo "Symbolic link already exists, skipping..."
  else 
    echo "Creating a symbolic link into '/usr/local/bin' folder..."
    ln -s "$HYPA_GIT_ROOT" "$HYPA_GIT_SYMLINK"
  fi     

  echo "Hypa-git installed successfully! Enjoy :)"
  exit 0
}

init "$@"