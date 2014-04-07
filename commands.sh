# create directories even on multiple levels and enters into it
mdcd() {
  mkdir -p "$@" && builtin cd "$@"
}

# clever cd
#
# with multiple params it replaces 'param1' in the current dir name to 'param2' and enters into that dir
#
# with one param, if that contains several dots, then it resolves each ..[.]* to ..[/..]* and enters into that
# e.g. '...' means '../..', while '.....' means '../../../..'
#
# otherwise does the regular cd
cd() {
  if [[ "$2" != "" ]]
  then
    # two params
    dir="$PWD"
    pattern="\/$1"
    replacement="/$2"
    dir="${dir/$pattern/$replacement}"
    builtin cd "$dir"
  elif [[ "$1" != "" && `echo "$1" | grep -v "\.\.\."` == "" ]]
  then
    # one param with several dots
    dir="$1"
    pattern="..."
    replacement="../.."
    while [[ `echo "$dir" | grep "\.\.\."` != "" ]]
    do
      dir="${dir/$pattern/$replacement}"
    done
    builtin cd "$dir"
  else
    # one regular param or no params
    if [[ -f "$1" ]]
    then
      # trying to cd into a file? cd it directory instead
      builtin cd "$(dirname "$1")"
    else
      builtin cd "$@"
    fi
  fi
}

# creates a new file with u+rwx and invokes emacs on it
en() {
  file="$@"
  if [[ -e "$file" ]]
  then
    echo "File [$file] already exists. Aborting..."
  else
    touch "$file"
    chmod u+rwx "$file"
    e "$file"
  fi
}

# colored diff
diffc() {
  diff -b -B --ignore-all-space --ignore-blank-lines --ignore-space-change --minimal "$@" | ~/bin/colordiff
}

#mu commander
mc() {
  if [[ -n "$1" ]]
  then
    dir1="$1"
    if [[ -n "$2" ]]
    then
      dir2="$2"
    fi
  else
    dir1="."
    dir2="."
  fi
  dir1="$(/usr/local/bin/greadlink -m "$dir1")"
  dir2="$(/usr/local/bin/greadlink -m "$dir2")"
  /Applications/muCommander.app/Contents/MacOS/JavaApplicationStub "$dir1" "$dir2" 1>/dev/null 2>/dev/null &
}
