# sets the prompt be double lined with the format of
# <user>@<host> <path>                        <git_info_in_a_git_dir> <exit_code_of_last_comment_if_not_zero> <current_time_HH:mm:ss>

# Requires bash 4.x+
# Setup requirements on Mac
#   brew install bash
#   sudo mv /bin/bash /bin/bash.bak
#   sudo ln -s /usr/local/Cellar/bash/4.2.45/bin/bash /bin/bash

# initializing color variables
. ~/.custom/bin/initcolors.sh

printPrompt() {
  local EXITCODE=${?#0}
  local OPEN_SQ_BRAQCKET="["
  local CLOSE_SQ_BRACKET="]"

  # takes an associative array name and optionally a key name
  # returns with the value found for that key, or returns with the item with 'default' key
  # (even in case when the key parameter is not specified),
  # or returns with the key if the value for the 'default' key was 'KEY'
  # the associative array must contain an item with 'default' key which may have a value of 'KEY'
  getValue() {
    local key="$2"
    local arrayName="$1"
    if [[ -z "${key}" ]]
    then
      key="default"
    fi
    local color="$(eval echo "\${${arrayName}[${key}]}")"
    if [[ -z "${color}" ]]
    then
      color="$(eval echo "\${${arrayName}[default]}")"
      if [[ "${color}" == "KEY" ]]
      then
        color="${key}"
      fi
    fi
    echo -n "${color}"
  }

  # If text is empty then returns with empty text, otherwise colored text
  getPart() {
    local color="$1"
    local text="$2"

    if [[ -z "${text}" ]]
    then
      echo -n ""
    else
      echo -n "${color}${text}"
    fi
  }

  # # specify prompt background color per user, not used currently
  # declare -A PROMPT_BG_COLORS
  # PROMPT_BG_COLORS=(
  #   [robertfa]=""
  #   [root]=${BG_RED}
  #   [default]=""
  # )
  # COLOR_PROMPT_BG='$(getValue PROMPT_BG_COLORS ${USER})'
  COLOR_PROMPT_BG=""

  # the <user>
  COMMAND_USER='${USER}'
  declare -A COLORS_USER=(
    [robert]=${FG_LIGHT_CYAN}
    [jenkins]=${FG_PURPLE}
    [default]=${FG_LIGHT_CYAN}
  )
  COLOR_USER='$(getValue COLORS_USER ${USER})'

  # the @ sign
  COMMAND_AT='@'
  COLOR_AT='${FG_YELLOW}'

  # host
  # specify color for for each <host> plus for the 'default'
  declare -A COLORS_HOST=(
    [localhost]=${FG_LIGHT_CYAN}
    [Robert-Laptop]=${FG_LIGHT_CYAN}
    [Robert-Fajtas-MacBook-Pro.local]=${FG_LIGHT_CYAN}
    [default]=${FG_LIGHT_PURPLE}
  )
  # abbreviation of each <host> for the tab name of konsole, plus ['default']=KEY
  declare -A HOST_ABBREVIATION=(
    [localhost]=l
    [Robert-Fajtas-MacBook-Pro.local]=l
    [Robert-Laptop]=l
    [default]=KEY
  )
  # no surrounding single or double quotes here
  COMMAND_HOST='$(getValue HOST_ABBREVIATION ${HOSTNAME})'
  COLOR_HOST='$(getValue COLORS_HOST ${HOSTNAME})'

  # <path>
  COMMAND_PWD="'${PWD}'"
  COLOR_PWD='${FG_YELLOW}'

  # <time>
  COMMAND_TIME='$(date +%H:%M:%S)'
  COLOR_TIME='${FG_YELLOW}'

  # <exit code>
  COMMAND_EXITCODE='\ ${EXITCODE}\ '
  COLOR_EXITCODE='${BG_BLUE}${FG_YELLOW}'

  # <git>
  COMMAND_GIT=\$\(/usr/local/bin/vcprompt\ -f\ \'[\${FG_GREEN}%a%m%u\ %b${FG_RED}\%a\%m\%u\${FG_YELLOW}]\'\)
  declare -A COLORS_GIT=(
    [default]="${FG_YELLOW}"
  )
  COLOR_GIT=\"\$\(getValue\ COLORS_GIT\)\"
  COLOR_GIT_BRACKETS="${FG_YELLOW}"
  COLOR_GIT_BRANCH="${FG_LIGHT_CYAN}"
  COLOR_GIT_CHANGES="${FG_RED}"
  COLOR_GIT_STASH="${FG_RED}"

  getLengthOfVisiblePart() {
    local text="$1"
    # filtering out color control characters
    text="$(echo -n "${text}" | sed -e "s/[^[:print:]]\[[0-9]*\(;[0-9]*\)*m//g")"
    echo -n ${#text}
  }

  composeIndentation() {
    local text="$1$2"
    local textLength=$(getLengthOfVisiblePart "${text}")
    local length=$(( ${COLUMNS} - ${textLength} ))
    printf "% ${length}s"
  }

  getGitDir() {
    local dir="${PWD}"

    while [ "${dir}" != "/" ]
    do
      if [ -d "${dir}/.git" ]
      then
        echo "${dir}"
        break
      fi
      dir=`dirname "${dir}"`
    done
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
          echo $(/usr/local/bin/gdate '+%s%6N')
      else
          local  stime=$1
          etime=$(/usr/local/bin/gdate '+%s%6N')

          if [[ -z "${stime}" ]]; then stime=${etime}; fi

          dt=$((etime - stime))
          dmm=$((dt % 1000000))
          ds=$(((dt / 1000000) % 60))
          dm=$(((dt / 60000000) % 60))
          dh=$((dt / 3600000000))
          printf '%d:%02d:%02d.%06d  %d' ${dh} ${dm} ${ds} ${dmm} ${dt}
      fi
  }

  log() {
    echo "{$@}" >&2
  }

  composeGitPart() {
    local gitDir="$(getGitDir)"
    if [[ -n "${gitDir}" ]]
    then
      local branch="$(git branch | grep "^* ")"
      branch="${branch:2}"
      echo -n " ${COLOR_GIT_BRACKETS}${COLOR_PROMPT_BG}${OPEN_SQ_BRAQCKET}${COLOR_GIT_BRANCH}${COLOR_PROMPT_BG}"
      if [[ "$branch" == "(no branch)" ]]
      then
        branch=$(git log -1 --oneline --abbrev=5)
        branch="${branch:0:5}"
        echo -n "<${branch}>"
      else
        echo -n "${branch}"
      fi
      branchSha="${branch}"

      if [[ "${branch}" =~ 'HEAD detached at' ]]
      then
        branchSha=$(git log -1 --oneline --abbrev=5)
        branchSha="${branchSha:0:5}"
      fi

      # staged files
      git diff --quiet --cached --exit-code
      if [[ ${?#0} ]]
      then
        local changeIndicator="${changeIndicator}+"
      fi
      # modified files
      git diff --quiet --exit-code
      if [[ ${?#0} ]]
      then
        changeIndicator="${changeIndicator}*"
      fi
      # untracked files
      if [[ -n $(git ls-files "${gitDir}" --other --exclude-standard) ]]
      then
       changeIndicator="${changeIndicator}?"
      fi
      # unpushed commits
      if [[ -n $(git log ${branchSha} --not --remotes --oneline) ]]
      then
       changeIndicator="${changeIndicator}!"
      fi
      # stashed stack depth
      local stashStackDepth="$(git stash list | wc -l | cut -f8 -d' ' | grep -v '^ 0$')"
      if [[ ${changeIndicator} ]]
      then
        getPart "${COLOR_GIT_CHANGES}${COLOR_PROMPT_BG}" " ${changeIndicator}"
      fi
      if [[ "${stashStackDepth}" != "0" ]]
      then
        getPart "${COLOR_GIT_STASH}${COLOR_PROMPT_BG}" " ${stashStackDepth}"
      fi
      echo -n "${COLOR_GIT_BRACKETS}${COLOR_PROMPT_BG}${CLOSE_SQ_BRACKET}"
    else
      echo -n ""
    fi
  }

  composeBeginning() {
    eval "getPart "${COLOR_USER}${COLOR_PROMPT_BG}" "${COMMAND_USER}""
    eval "getPart "${COLOR_AT}${COLOR_PROMPT_BG}" "${COMMAND_AT}""
    eval "getPart "${COLOR_HOST}${COLOR_PROMPT_BG}" "${COMMAND_HOST}""
    echo -n " "
    eval "getPart "${COLOR_PWD}${COLOR_PROMPT_BG}" "${COMMAND_PWD}""
  }

  composeEnd() {
    composeGitPart
    if [[ ${EXITCODE} ]]
    then
      echo -n " "
      eval "getPart "${COLOR_EXITCODE}" "${COMMAND_EXITCODE}""
      echo -n "${NO_COLOR}${COLOR_PROMPT_BG} "
    else
      echo -n " "
    fi
    eval "getPart "${COLOR_TIME}${COLOR_PROMPT_BG}" "${COMMAND_TIME}""
  }

  ###########################################
  ####  body of printPrompt starts here  ####
  ###########################################

  # startTime=$(timer)
  echo -n "${COLOR_PROMPT_BG}"
  local beginnig="$(composeBeginning)"
  local end="$(composeEnd)"

  echo -n "${beginnig}"
  composeIndentation "${beginnig}" "${end}"
  echo "${end}${NO_COLOR}"
  echo "> "
  # log 1: $(timer ${startTime})
}

export PS1="\`printPrompt\`"
