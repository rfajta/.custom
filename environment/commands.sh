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
# mc() {
#   if [[ -n "$1" ]]
#   then
#     dir1="$1"
#     if [[ -n "$2" ]]
#     then
#       dir2="$2"
#     fi
#   else
#     dir1="."
#     dir2="."
#   fi
#   dir1="$(/usr/local/bin/greadlink -m "$dir1")"
#   dir2="$(/usr/local/bin/greadlink -m "$dir2")"
#   /Applications/muCommander.app/Contents/MacOS/JavaApplicationStub "$dir1" "$dir2" 1>/dev/null 2>/dev/null &
# }

# with single arg
#   grep -rI "$@" *
#
# with multiple arg
#   find . -name "$fileNamePattern" | xargs grep -I "$@"
# where fileNamePattern is considered a ready pattern if hasa dot,
# or considered a file extension only if there is no dot
r() {
  if [[ "$2" != "" ]]
  then
    fileNamePattern="$1"
    # the below *.* must not be quoted to check if the pattern contains a .
    if [[ "$1" == *.* ]]
    then
      # . in the filename, so assume it is a ready pattern already, and not only an extension
      fileNamePattern="$1"
    else
      # if no . in the pattern then assume it is a file extension
      fileNamePattern="*.$1"
    fi
    shift
    find . -name "$fileNamePattern" | xargs grep -I "$@"
  else
    grep -rI "$@" * 2>/dev/null
  fi
}


t() {
  if [[ $# == 0 ]]
  then
    git s
  else
    if [[ "$1" == "am" ]]
    then
      shift
      git ac "$@"
    else
      git "$@"
    fi
  fi 
}

f() {
  if [[ $# == 0 ]]
  then
    find .
  else
    find . -name "$@"
  fi
}

fl() {
  if [[ $# == 0 ]]
  then
    find . -exec ls -lA {} \;
  else
    find . -name "$@" -exec ls -lA {} \;
  fi
}

ff() {
    if [[ $# == 0 ]]
  then
    find . -type f
  else
    find . -type f -name "$@"
  fi
}

ffl() {
    if [[ $# == 0 ]]
  then
    find . -type f -exec ls -lA {} \;
  else
    find . -type f -name "$@" -exec ls -lA {} \;
  fi
}

m() {
  goals=""
  case $1 in
    "c") goals="clean " ;;
    "cd") goals="clean deploy " ;;
    "ci") goals="clean install " ;;
    "cp") goals="clean package " ;;
    "ct") goals="clean test " ;;
    "p") goals="package " ;;
    "t") goals="test " ;;
    "i") goals="install " ;;
    "d") goals="deploy " ;;
    "qci") goals="clean install -Dmaven.test.skip=true" ;;
    "qcp") goals="clean package -Dmaven.test.skip=true" ;;
    "qct") goals="clean test -Dmaven.test.skip=true" ;;
    "qp") goals="package -Dmaven.test.skip=true" ;;
    "qt") goals="test -Dmaven.test.skip=true" ;;
    "qi") goals="install -Dmaven.test.skip=true" ;;
#      "") goals=" " ;;
    *) mvn-color "$@" ;;
  esac
  if [[ -n "${goals}" ]]
  then
    shift
    mvn-color ${goals} "$@"
  fi
}