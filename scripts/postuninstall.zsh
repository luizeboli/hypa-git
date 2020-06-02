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
  echo "Trying to uninstall hypa-git..."

  [[ ! -f "$HYPA_GIT_ROOT" ]] && echo "Unable to find hypa-git root file..." && exit 1

  cd ..
  
  echo "Deleting 'hypa-git' directory from '$HYPA_GIT_DEST'..."
  rm -r -f "$HYPA_GIT_DEST" || { echo "Unable to delete folder '$HYPA_GIT_DEST'..." && exit 1 } 

  if [[ -h "$HYPA_GIT_SYMLINK" ]]; then
    echo "Deleting symlink..."
    rm "$HYPA_GIT_SYMLINK"
  else 
    echo "Symlink deleted, skipping..."
    ln -s "$HYPA_GIT_ROOT" "$HYPA_GIT_SYMLINK"
  fi     

  echo "Hypa-git uninstalled successfully! See ya! :)"
  exit 0
}

init "$@"