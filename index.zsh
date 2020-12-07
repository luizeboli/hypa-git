#!/usr/bin/env zsh
#########################################
#             Hypa Git ZSH              #
#########################################
# Author: Luiz Felicio                  #
# License: MIT                          #
# https://github.com/luizeboli/hypa-git #
#########################################

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------
set -eu

# Common line break var
NEW_LINE='
'
# Divider for logs
DIVIDER="-----------------------------------------------------------------"

# Global vars used by functions
HYPA_GIT_ROOT="$HOME/.hypa-git"
HYPA_GIT_LAST_TAG=""
HYPA_GIT_NEW_VERSION=""
HYPA_GIT_NEW_VERSION_NO_RC=""
HYPA_GIT_IS_MAJOR="false"
HYPA_GIT_IS_MINOR="false"
HYPA_GIT_IS_PATCH="false"
HYPA_GIT_BRANCHES=""

HYPA_GIT_VERSION="1.1.1"

# Check if zsh is installed and exit if not
[[ ! $(which zsh) ]] && { echo "\nZSH not installed." && exit 1 }

# Check if root dir exists and exit if not.
if [[ ! -d "$HYPA_GIT_ROOT" ]]; then
  echo "\nUnable to find root dir: '$HYPA_GIT_ROOT'.\nDid you move it?"
  exit 1
fi

# Source utils
source "$HYPA_GIT_ROOT/utils/functions.zsh"

# ------------------------------------------------------------------------------
# Steppers
# ------------------------------------------------------------------------------

usage() {
  if [[ "$#" -gt 0 ]]; then
    hypa::error "Invalid option: $1"
  else
    hypa::print "CLI to create RC's and merge branches."
  fi

  hypa::print "\n${bold}USAGE:"
  hypa::print "  hypa-git [options]"
  hypa::print "\n${bold}OPTIONS:"
  hypa::print "  -nv, --new-version  New RC name."
  hypa::print "  -b, --branches      Branches to merge on new RC. ${bold}They must be in double quotes separated by a space."
  hypa::print "  -major              Increments a major version from last tag."
  hypa::print "  -minor              Increments a minor version from last tag."
  hypa::print "  -patch              Increments a patch version from last tag."
  hypa::print "\n${bold}NOTES:"
  hypa::print "  If no new version option, hypa-git will increment version based on semver option"
  hypa::print "  If no semver option, hypa-git will consider the new RC as a patch."
  hypa::print "  If no branch option, hypa-git will only create and push the new RC."
}

get-new-version() {
  hypa::info "Getting last tag and incrementing version..."

  local 'major' 'minor' 'patch' 'version'

  version=(${(s:.:)HYPA_GIT_LAST_TAG})
  major="$version[1]"
  minor="$version[2]"
  patch="$version[3]"

  # We should check if user has chosen version type
  # If not, we consider it as a patch
  # We should also check if user specified RC name
  # If so, consider it.
  # @TODO: Allow only one type.
  if [[ -z $HYPA_GIT_NEW_VERSION ]]; then    
    if [[ $HYPA_GIT_IS_MAJOR == true ]]; then
      HYPA_GIT_NEW_VERSION="$(($major+1)).0.0-RC"
      HYPA_GIT_NEW_VERSION_NO_RC="$(($major+1)).0.0"
    elif [[ $HYPA_GIT_IS_MINOR == true ]]; then
      HYPA_GIT_NEW_VERSION="$major.$(($minor+1)).0-RC"
      HYPA_GIT_NEW_VERSION_NO_RC="$major.$(($minor+1)).0"
    else
      HYPA_GIT_NEW_VERSION="$major.$minor.$(($patch+1))-RC"
      HYPA_GIT_NEW_VERSION_NO_RC="$major.$minor.$(($patch+1))"
    fi
  fi
}

create-new-version() {  
  if [[ -z $(git branch --list $HYPA_GIT_NEW_VERSION) && -z $(git branch -a | grep "remotes/origin/$HYPA_GIT_NEW_VERSION") ]]; then
    hypa::info "Creating new branch '$HYPA_GIT_NEW_VERSION' and doing a checkout..."
    hypa::exec-cmd "git checkout -b $HYPA_GIT_NEW_VERSION tags/$HYPA_GIT_LAST_TAG" || { hypa::error "Unable to create a new branch, please see above output..." && exit 1 }

    hypa::info "Pushing '$HYPA_GIT_NEW_VERSION' to upstream..."
    hypa::exec-cmd "git push -u origin $HYPA_GIT_NEW_VERSION" || { hypa::error "Unable to push to upstream, please see above output..." && exit 1 }
  else
    hypa::warn "Branch '$HYPA_GIT_NEW_VERSION' already exists, skipping to checkout..." 
    hypa::exec-cmd "git checkout $HYPA_GIT_NEW_VERSION" || { hypa::error "Unable to checkout branch '$HYPA_GIT_NEW_VERSION', please see above output..." && exit 1}

    hypa::info "Pulling commits from '$HYPA_GIT_NEW_VERSION'..."
    hypa::exec-cmd "git pull" || { hypa::error "Unable to pull from '$HYPA_GIT_NEW_VERSION', please see above output..." && exit 1 }
  fi
}

update-package-version() {
  hypa::info "Checking for a package.json file so we can update it's version..."
  if [[ -f "./package.json" ]]; then
    hypa::info "Updating package.json version..."
    perl -0777 -pi -e "s/\.*\"version\".*/\"version\": \"$HYPA_GIT_NEW_VERSION_NO_RC\",/" package.json
    if [[ $? -eq "0" ]]; then
      hypa::exec-cmd "git commit -am \"chore: update package.json version\"" || { hypa::error "Unable to commit package.json, please see above output..." && exit 1 }
      hypa::exec-cmd "git push" || { hypa::error "Unable to push package.json, please see above output..." && exit 1 }
      hypa::success "Successfully updated package version..."
    else
      hypa:error "Could not update package version..."
    fi
   else
    hypa::info "File not found, doing nothing..."
  fi
}

merge-branches() {
  [[ -z $HYPA_GIT_BRANCHES ]] && return

  local 'conflicts' 'notmerged'
  conflicts=()
  notmerged=()

  for branch in $(echo "$HYPA_GIT_BRANCHES"); do
    hypa::info "Pulling commits from '$branch'..."
    hypa::exec-cmd "git merge origin/$branch" || { 
      echo "\n" && hypa::error "Unable to pull commits from $branch, please see above output... " && exit 1
     }

    hypa::info "Merging '$branch' into '$HYPA_GIT_NEW_VERSION'..."
    hypa::exec-cmd "git merge $branch --commit --progress -m \"Merge branch $branch into $HYPA_GIT_NEW_VERSION\"" || {
      if [[ $? -eq "128" ]]; then
        notmerged=($notmerged $branch)
      else
        conflicts=($conflicts $branch)
      fi
    }
  done

  hypa::info "Pushing successful merges..."
  hypa::exec-cmd "git push" || { hypa::error "Unable to push merges, please see above output... " && exit 1 }

  [[ ${#conflicts[@]} -gt 0 || ${#notmerged[@]} -gt 0 ]] && echo "$NEW_LINE"

  if [[ ${#conflicts[@]} -gt 0 ]]; then
    hypa::warn "Merging your branches (${(j:, :)conflicts}) resulted in some conflicts\nFix them and commit your changes..."
    hypa::open-code
  fi

  if [[ ${#notmerged[@]} -gt 0 ]]; then
    hypa::error "Branches (${(j:, :)notmerged}) were not merged\nDue to conflicts with unmerged files, fix them and run 'hypa-git' again..."
    exit 1
  fi
}

# @TODO: Interactive mode
interactive() {
  echo "INTER"
}

validate-options() {
  [[ "$#" -eq 0 ]] && { usage && exit 1 }

  # We aren't using 'getopts' because this command can't parse long options
  # Validate parameters
  while [[ "$#" -gt 0 ]]; do
      case $1 in
          -nv | --new-version )   shift
                                  [[ -n ${1+x} ]] && HYPA_GIT_NEW_VERSION=$1
                                  ;;
          -major )                HYPA_GIT_IS_MAJOR=true
                                  ;;
          -minor )                HYPA_GIT_IS_MINOR=true
                                  ;;
          -patch )                HYPA_GIT_IS_PATCH=true
                                  ;;
          -b | --branches )       
                                  shift
                                  [[ -n ${1+x} ]] && HYPA_GIT_BRANCHES="$1"
                                  ;;
          -h | --help )           usage
                                  exit
                                  ;;
          -i | --interactive )    interactive
                                  exit
                                  ;;
          * )                     usage "$1"
                                  exit 1
      esac
      [[ "$#" -ne 0 ]] && shift
  done
}

# ------------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------------
init() {
  hypa::welcome
  validate-options "$@"
 
  hypa::is-git       || { hypa::error "Working directory isn't a git repository." && exit 1 }
  hypa::is-git-dirty && { hypa::error "Please commit your changes first." && exit 1 }
  hypa::git-fetch    || { hypa::error "Unable to fetch origin, please see above error..." && exit 1 }
  hypa::git-last-tag || { hypa::error "Could not get last tag name, please see above error..." && exit 1 }

  get-new-version
  create-new-version
  update-package-version
  merge-branches

  hypa::success "Job done :)\nEnjoy!"

  exit 0
}

init "$@"