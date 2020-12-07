# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

# Use tput to set colors
if [[ ! -z $(which tput 2> /dev/null) ]]; then
  reset=$(tput sgr0)
  bold=$(tput bold)
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  magenta=$(tput setaf 5)
  cyan=$(tput setaf 6)
fi

# Custom messages formatter
hypa::print() {
  local color=$1 rest=${@:2}
  echo "$reset$color$rest$reset"
}

hypa::info()    { hypa::print "$DIVIDER\n$cyan"            "[HYPA 💭 ]: $@" ; }
hypa::success() { hypa::print "$DIVIDER\n$bold$green"      "[HYPA ✨ ]: $@ \n$reset$DIVIDER" ; }
hypa::error()   { hypa::print "$bold$red"                  "[HYPA ❌ ]: $@ \n$reset$DIVIDER" ; }
hypa::warn()    { hypa::print "$yellow"                    "[HYPA ⚠️ ]: $@" ; }

# Check if working directory is a git repository
hypa::is-git() {
  [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]
}

hypa::git-fetch() {
  hypa::info "Fetching from origin before start..."
  git fetch --all --prune
}

# Check if git is dirty
hypa::is-git-dirty() {
  [[ ! -z $(git status --porcelain) ]]
}

# Get last tag by chronological commit order
hypa::git-last-tag() {
  HYPA_GIT_LAST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
}

# Exec command with a label to distinguish git outputs
hypa::exec-cmd() {
  local 'label'
  [[ "$#" -gt 1 && $2 == "false" ]] && label="" || label="\n${magenta}GIT-OUTPUT$reset:\n" 
  echo -n "$label" && eval ${1}
}

#Open vscode if installed
hypa::open-code() {
  [[ $(which code) ]] && code .
}

# Prints a welcome message
hypa::welcome() {
  echo '
   __ __                   _____ _  __ 
  / // /__ __ ___  ___ _  / ___/(_)/ /_
 / _  // // // _ \/ _ `/ / (_ // // __/
/_//_/ \_, // .__/\_,_/  \___//_/ \__/ 
      /___//_/                                                                                                 
'
  hypa::print "${yellow}Version: 0.1.9-alpha\n"
}