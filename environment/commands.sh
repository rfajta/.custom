storelogs() {
  for logfile in $@
  do
    # logfile="$1"
    if [[ -f "$logfile" ]]
    then
      echo "Persisting session history from $logfile to ${HISTFILE:-$HOME/.bash_history}"
      cat "$logfile" >> "${HISTFILE:-$HOME/.bash_history}"
      rm "$logfile"
    else
      echo "[$logfile] provided as argument does not exist or is not a file"
    fi
  done
}


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
# with no params
#   - trying to cd into a file? cd its directory instead
#   - does the regular cd
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
    if [[ "$1" == "code" ]]
    then
      shift
      find . -name "*.java" -or -name "*.scala" | xargs grep -I "$@"
    else      
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
    fi
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

# find files and dirs matching with name
f() {
  if [[ $# == 0 ]]
  then
    find . 2>/dev/null
  else
    find . -name "$@" 2>/dev/null
  fi
}

# open in an editor the files and dirs matching with name
fe() {
  if [[ $# == 0 ]]
  then
    find . -exec ls -lA {} \; 2>/dev/null
  else
    find . -name "$@" -exec subl {} \; 2>/dev/null
  fi
}

# list files and dirs matching with name
fl() {
  if [[ $# == 0 ]]
  then
    find . -exec ls -lA {} \; 2>/dev/null
  else
    find . -name "$@" -exec ls -lA {} \; 2>/dev/null
  fi
}

# find files but not dirs matching with name
ff() {
    if [[ $# == 0 ]]
  then
    find . -type f 2>/dev/null
  else
    find . -type f -name "$@" 2>/dev/null
  fi
}

# list files but not dirs matching with name
ffl() {
    if [[ $# == 0 ]]
  then
    find . -type f -exec ls -lA {} \; 2>/dev/null
  else
    find . -type f -name "$@" -exec ls -lA {} \; 2>/dev/null
  fi
}

# m() {
#   goals=""
#   case $1 in
#     "c") goals="clean " ;;
#     "cd") goals="clean deploy " ;;
#     "ci") goals="clean install " ;;
#     "cp") goals="clean package " ;;
#     "ct") goals="clean test " ;;
#     "cc") goals="clean compile -Dfrontend.skip=true" ;;
#     "p") goals="package " ;;
#     "t") goals="test " ;;
#     "i") goals="install " ;;
#     "d") goals="deploy " ;;
#     "qci") goals="clean install -Dmaven.test.skip=true" ;;
#     "qcp") goals="clean package -Dmaven.test.skip=true" ;;
#     "qct") goals="clean test -Dmaven.test.skip=true" ;;
#     "qp") goals="package -Dmaven.test.skip=true" ;;
#     "qt") goals="test -Dmaven.test.skip=true" ;;
#     "qi") goals="install -Dmaven.test.skip=true" ;;
# #      "") goals=" " ;;
#     *) mvn-color "$@" ;;
#   esac
#   if [[ -n "${goals}" ]]
#   then
#     shift
#     if [[ "$1" != "-withui" ]] && [[ "$1" != "--withui" ]]
#     then
#       goals="${goals}"" -Dfrontend.skip=true"
#       echo 'SKIPPING UI'
#     else
#       echo 'HAVING UI'
#       shift
#     fi
#     # eval mvn-color ${goals} -Djava.library.path=/usr/local/lib "$@"
#     eval mvn-color ${goals} "$@"
#   fi
# }


function preexec() {
  timer=${timer:-$SECONDS}
}

function precmd() {
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    export EXEC_TIME="${timer_show}"
    unset timer
  fi
}

m() {
  goals=""
  param="$1"
  notest=""
  for i in $(seq 1 ${#param})
  do
    case ${param:i-1:1} in
      "c") goals="$goals clean" ;;
      "d") goals="$goals deploy" ;;
      "i") goals="$goals install" ;;
      "o") goals="$goals compile" ;;
      "t") goals="$goals test" ;;
      "f") goals="$goals fmt:format" ;;
      "p") goals="$goals package" ;;
      "c") goals="$goals clean" ;;
      "q") notest=" -Dmaven.test.skip=true" ;;
      *) goals="$param" ; return ;;
    esac
  done
  goals="$goals$notest"
  echo "Maven goals:$goals $@"
  echo ""
  if [[ -n "${goals}" ]]
  then
    shift
    if [[ "$1" != "-withui" ]] && [[ "$1" != "--withui" ]]
    then
      goals="${goals}"" -Dfrontend.skip=true"
      echo 'SKIPPING UI'
    else
      echo 'HAVING UI'
      shift
    fi
    # eval mvn-color ${goals} -Djava.library.path=/usr/local/lib "$@"
    eval mvn-color ${goals} "$@"
  fi
}

agg() {
  if [[ $# > 1 ]]
  then
    suffix="$1"
    shift
    ag -G "\.$suffix$" "$@"
  else
    ag $@
  fi
}

function make() {
  makeCommand="$(which make)"
  t=$(timer)
  echo "${FG_CYAN}${BG_LIGHT_GREY}    Started at: "$(date +%H:%M:%S)"    ${NO_COLOR}" ; /usr/bin/time -o /dev/stdout -f "${FG_BLUE}${BG_LIGHT_GREY}    Execution time: %E    ${NO_COLOR}" "${makeCommand}" "$@"
  makeErrorCode=$?
  ellapseSeconds=$(timer ${t} | cut -f1 -d.)
  echo "$(date +%Y-%m-%d),${ellapseSeconds},make $@" >> ~/damlBuildAndRunTime.txt
  return $makeErrorCode
  # (paplay /usr/share/sounds/ubuntu/stereo/service-logout.ogg && paplay /usr/share/sounds/ubuntu/stereo/service-login.ogg) &
}

  # If called with no arguments a new timer is returned.
  # If called with arguments the first is used as a timer
  # value and the elapsed time is returned in the form HH:MM:SS.
  #
  # Example:
  #  t=$(timer)
  #  printf 'Elapsed time: %s\n' $(timer ${t})
  function timer() {
      if [[ $# -eq 0 ]]; then
          echo $(date '+%s%6N')
      else
          local  stime=$1
          etime=$(date '+%s%6N')

          if [[ -z "${stime}" ]]; then stime=${etime}; fi

          dt=$((etime - stime))
          dmm=$((dt % 1000000))
          ds=$(((dt / 1000000) % 60))
          dm=$(((dt / 60000000) % 60))
          dh=$((dt / 3600000000))
          printf '%d:%02d:%02d.%06d  %d' ${dh} ${dm} ${ds} ${dmm} ${dt}
      fi
  }

function em() {
  while [[ $# -gt 0 ]]
  do
    partialFile="${1}"
    shift
    echo "partialFile: [${partialFile}]"
    fileName="$(echo "${partialFile}" | grep -o "\/[^\/]*$" | tr -d "/")"
    echo "fileName: [${fileName}]"
    file="$(f "${fileName}")"
    echo "file: [${file}]"
    e "${file}"
    echo "done"
  done
}

function elm() {
  msgType="$1"
  files="$(f 2*.xml | grep "\-\-\-[^\-]*\-${msgType}\-")"
  echo "files: [${files}]"
  e $files
  # lm | grep -o "/[^/]*$" | tr -d "/" | grep "\-"
}

function agdt () {
  ag -G "\.daml$" "$@" app/daml-model/src/DA/ASX/Test/
}

function lm() {
  changedDir="false"
  if [[ "$(basename "`pwd`")" != "logs" ]]
  then
    cd logs
    changedDir="true"
  fi
  if (($# < 1))
  then
    lmsimple | cat -b | sed -e "s/\(^ *[0-9]*\)\(.*\)/\1\2\1/" | grep "^ *[0-9]*\|[0-9]*$\|[a-z]\+-[0-9]*"
    # echo "Provide one or more numbers as parameters" 
  else
    lines="$(echo "$@ " | sed -e "s/ /p;/g")"
    files="$(lmsimple | sed -n "$lines" | cut -d/ -f3)"
    echo "$files"
    echo "$files" | xargs -I % sh -c 'subl $(find . -name %)'
  fi
  if [[ "$changedDir" == "true" ]]
  then
    cd - 2>&1 >/dev/null
  fi
}

function worldclock () { 
  TZONES='America/New_York Europe/London Europe/Budapest Asia/Hong_Kong Australia/Sydney GMT UTC';
  for TZONE in ${TZONES[@]};
  do
    echo "$(echo ${TZONE} | cut -d'/' -f2 | sed 's/_/ /g') | $(TZ=$TZONE date +"%H:%M   %d/%m/%Y (%z %Z)")";
  done | column -t -s'|'
}