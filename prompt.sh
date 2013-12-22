# sets the prompt be double lined with the format of 
# <user>@<host> <path>                        <git_info_in_a_git_dir> <exit_code_of_last_comment_if_not_zero> <current_time_HH:mm:ss>

# initializing color variables
. ~/.custom/initcolors.sh

SPACE=" "
OPEN_SQ_BRAQCKET="["
CLOSE_SQ_BRACKET="]"

# takes an associative array name and optionally a key name
# returns with the value found for that key, or returns with the item with 'default' key 
# (even in case when the key parameter is not specified),
# or returns with the key if the value for the 'default' key was 'KEY'
# the associative array must contain an item with 'default' key which may have a value of 'KEY'
getValue() {
  local key="$2"
  if [[ -z "$key" ]]
  then
    key="default"
  fi
  local color=""
  color="$(eval echo "\${$1[$key]}")"
  if [[ -z "$color" ]]
  then
    color="$(eval echo "\${$1[default]}")"
    if [[ "$color" == "KEY" ]]
    then
      color="$key"
    fi
  fi
  echo -n "$color"
}

getPart() {
  local COLOR="$1"
  local TEXT="$2"
  if [[ -z "$TEXT" ]]
  then
    echo ""
  else
    echo "$COLOR""$TEXT""$NO_COLOR"
  fi
}

# the <user>
COMMAND_USER="\$USER"
declare -A COLORS_USER=(
  [robertfa]=$FG_GREEN
  [jenkins]=$FG_PURPLE
  [default]=$FG_CYAN
)
COLOR_USER=\$\(getValue\ COLORS_USER\ \$USER\)


# the @ sign 
COMMAND_AT="@"
declare -A COLORS_AT=(
  [default]="$FG_BROWN"
)
COLOR_AT=\$\(getValue\ COLORS_AT\)

# host
# specify color for for each <host> plus for the 'default'
declare -A COLORS_HOST=(
  [localhost]=$FG_CYAN
  [default]=$FG_LIGHT_PURPLE
)
# abbreviation of each <host> for the tab name of konsole, plus ['default']=KEY
declare -A HOSTS HOSTS=(
  [localhost]=l
  [default]=KEY
)
# no surrounding single or double quotes here
COMMAND_HOST=\"\$\(getValue\ HOSTS\ \$HOSTNAME\)\"
COLOR_HOST=\$\(getValue\ COLORS_HOST\ \$HOSTNAME\)

# <path>
COMMAND_PWD=\"\${PWD}\"
declare -A COLORS_PWD=(
  [default]="$FG_BROWN"
)
COLOR_PWD=\$\(getValue\ COLORS_PWD\)

# <time>
COMMAND_TIME=\$\(date\ +%H:%M:%S\)
declare -A COLORS_TIME=(
  [default]="$FG_BROWN"
)
COLOR_TIME=\"\$\(getValue\ COLORS_TIME\)\"

# <exit code>
COMMAND_EXITCODE=\"\$\{SPACE\}\\$\{EXITCODE\}\$\{SPACE\}\" 
declare -A COLORS_EXITCODE=(
  [default]="$BG_BLUE$FG_YELLOW"
)
COLOR_EXITCODE=\"\$\(getValue\ COLORS_EXITCODE\)\"

# <git>
COMMAND_GIT=\$\(/usr/local/bin/vcprompt\ -f\ \'[\$FG_GREEN%a%m%u\ %b$FG_RED\%a\%m\%u\$FG_BROWN]\'\)
declare -A COLORS_GIT=(
  [default]="$FG_BROWN"
)
COLOR_GIT=\"\$\(getValue\ COLORS_GIT\)\"


##########

# color for <exit_code_of_last_comment_if_not_zero>
EXIT_CODE_COLOR="$BG_BLUE$FG_YELLOW"
EXEC_TIME_COLOR="$FG_BROWN"

# specify prompt background color
declare -A PROMPT_BG_COLORS
PROMPT_BG_COLORS=(
  [user1]=""
  [user2]=$BG_RED
  [default]=""
)

getLengthOfVisiblePart() {
  local text="$1"
  text="$(echo "$text" | sed -e "s/[^:print:]\[[0-9]*\(;[0-9]*\)*m[^:print:]//g")"
  echo ${#text}
}


getIndentation() {
  local text="$1$2"
  local textLength=$(getLengthOfVisiblePart "$text")
  local length=$(( $COLUMNS - $textLength + 1 ))
  printf "% ${length}s"
}

getGitDir() {
  local dir="$PWD"

  while [ "$dir" != "/" ]
  do 
    if [ -d "$dir/.git" ]
    then 
      echo "$dir"
      break
    fi
    dir=`dirname "$dir"`
  done
}

# If called with no arguments a new timer is returned.
# If called with arguments the first is used as a timer
# value and the elapsed time is returned in the form HH:MM:SS.
#
# Example:
#  t=$(timer)
#  printf 'Elapsed time: %s\n' $(timer $t)
function timer() {
    if [[ $# -eq 0 ]]; then
        echo $(/usr/local/bin/gdate '+%s%6N')
    else
        local  stime=$1
        etime=$(/usr/local/bin/gdate '+%s%6N')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        dmm=$((dt % 1000000))
        ds=$(((dt / 1000000) % 60))
        dm=$(((dt / 60000000) % 60))
        dh=$((dt / 3600000000))
        printf '%d:%02d:%02d.%06d  %d' $dh $dm $ds $dmm $dt
    fi
}

log() {
  echo "{$@}"
}

composeGitPart() {
  local gitDir="$(getGitDir)"
  if [[ -n "$gitDir" ]]
  then
    BRANCH=$(git branch | grep "^* ")
    BRANCH="${BRANCH:2}"
    PART7="$SPACE${FG_BROWN}${OPEN_SQ_BRAQCKET}${FG_CYAN}$BRANCH"
    # staged files
    git diff --quiet --cached --exit-code
    if [[ ${?#0} ]]
    then
      PART7_2="$PART7_2""+"
    fi
    # modified files
    git diff --quiet --exit-code
    if [[ ${?#0} ]]
    then
      PART7_2="$PART7_2""*"
    fi
    # untracked files
    if [[ -n $(git ls-files "$gitDir" --other --exclude-standard) ]]
    then
     PART7_2="$PART7_2""?"
    fi
   # unpushed commits
    if [[ -n $(git log $BRANCH --not --remotes --oneline) ]]
    then
     PART7_2="$PART7_2""!"
    fi
    # stashed stack depth
    PART7_3="$(git stash list | wc -l | cut -f8 -d' ' | grep -v '^ 0$')"
    if [[ $PART7_2 ]]
    then
      PART7="$PART7${FG_RED}$SPACE$PART7_2"
    fi
    if [[ "$PART7_3" != "0" ]]
    then
      PART7="$PART7${FG_RED}$SPACE$PART7_3"
    fi
    PART7="$PART7${FG_BROWN}${CLOSE_SQ_BRACKET}"
  else
    PART7=''
  fi
  echo -n "$PART7"
}


export PS1="\`
  EXITCODE=\${?#0}
  # fulltime=\$(timer)
  PART1=\$(getPart "$COLOR_USER" "$COMMAND_USER")
  PART2=\$(getPart "$COLOR_AT" "$COMMAND_AT")
  PART3=\$(getPart "$COLOR_HOST" "$COMMAND_HOST")
  PART4='$SPACE'
  PART5=\$(getPart "$COLOR_PWD" "$COMMAND_PWD")

  PART7=\"\$(composeGitPart)\"
  if [[ \$EXITCODE ]]
  then
    PART8=\"\$SPACE\$(getPart "$COLOR_EXITCODE" "$COMMAND_EXITCODE")\$SPACE\"
  else
    PART8='$SPACE'
  fi
  PART9=\$(getPart "$COLOR_TIME" "$COMMAND_TIME")

  T1="\$PART1\$PART2\$PART3\$PART4\$PART5"
  T2="\$PART7\$PART8\$PART9"

  echo -n "\$T1"
  getIndentation \"\$T1\" \"\$T2\"
  echo -n "\$T2"

# log 1: \$(timer \$fulltime)
\`
> "

