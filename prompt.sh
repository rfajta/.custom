# sets the prompt be double lined with the format of 
# <user>@<host> <path>                        <current_time_HH:mm:ss> <exit_code_of_last_comment_if_not_zero> (<exec_time_of_last_command_h:mm:ss>) 

# initializing color variables
. ~/.custom/initcolors.sh

# color for the @ sign 
AT_COLOR="$FG_BROWN" 

# color of the <path> 
PWD_COLOR="$FG_BROWN"

# color for <exit_code_of_last_comment_if_not_zero> 
EXIT_CODE_COLOR="$BG_BLUE$FG_YELLOW" 
TIME_COLOR="$FG_BROWN" 
EXEC_TIME_COLOR="$FG_BROWN" 

# specify prompt background color 
declare -A PROMPT_BG_COLORS 
PROMPT_BG_COLORS=(   
  [user1]=""   
  [user2]=$BG_RED   
  [default]=""
)

# specify color for for each <user> plus for the 'default' 
declare -A USER_COLORS USER_COLORS=(   
  [user1]=$FG_LIGHT_CYAN   
  [user2]=$FG_LIGHT_PURPLE   
  [user3]=$FG_LIGHT_PURPLE   
  [user4]=$FG_LIGHT_GREEN   
  [user5]=$FG_WHITE   
  [default]=$FG_GREEN 
)

# specify color for for each <host> plus for the 'default' 
declare -A HOST_COLORS HOST_COLORS=(   
  [host1]=$FG_LIGHT_CYAN
  [default]=$FG_PURPLE 
)

# abbreviation of each <user> for the tab name of konsole, plus ['default']=KEY 
declare -A TAB_USERSS TAB_USERSS=(   
  [user1]=u1   
  [user2]=u2   
  [user3]=u3   
  [user4]=u4   
  [user5]=u5   
  [default]=KEY 
)

# abbreviation of each <host> for the tab name of konsole, plus ['default']=KEY 
  declare -A TAB_HOSTS TAB_HOSTS=(   
  [host1]=h1   
  [default]=KEY 
)

# takes an associative array name and a key name
# returns with the value found for that key, or returns with the item with 'default' key,  
# or returns with the key if the value for the 'default' key was 'KEY' 
# the associative array must contain an item with 'default' key whcih may have a value of 'KEY' 
getValue() {   
  local key="$2"   
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

# setting up the prompt 
if [[ $TERM != dumb ]] ; 
then   
  DEFAULT_COLOR="$NO_COLOR$(getValue "PROMPT_BG_COLORS" "${USER}")$FG_BROWN"
fi   
  bgColor="$(getValue "PROMPT_BG_COLORS" "${USER}")"   
  colorUser="$(getValue "USER_COLORS" "${USER}")""${USER}$AT_COLOR@"   
  colorHost="$(getValue "HOST_COLORS" "${HOSTNAME}")""${HOSTNAME}"   
  colorPwd="$PWD_COLOR \${PWD}"   
  colorTime='$TIME_COLOR$(date +%H:%M:%S)' 
  tabHost="$(getValue "TAB_HOSTS" "${HOSTNAME}")" 
  tabUser="$(getValue "TAB_USERSS" "${USER}")" 

trap 'export commandExecutionStart=$(date +%s)' DEBUG 
export PS1="\` 
  ## capturing exit code from the previous command and setting exit code string 
  exitCode=\${?#0} 
  exitCodeLength=\${#exitCode} 
  if [[ \$exitCodeLength -eq 0 ]] 
  then 
    exitCodeLength=-2  
    colorExitCode=\"  \" 
  else
    colorExitCode=\" $EXIT_CODE_COLOR \$exitCode $DEFAULT_COLOR \" 
  fi
  ## calculating time spent since the start of the last command (see trap above) 
  commandExecutionEnd=\$(date +%s)
  commandExecutionTimeInSeconds=\$(( \$commandExecutionEnd - \$commandExecutionStart )) 
  commandExecutionTimeSeconds=\$((\$commandExecutionTimeInSeconds % 60)) 
  commandExecutionTimeMinutes=\$(((\$commandExecutionTimeInSeconds / 60) % 60)) 
  commandExecutionTimeHours=\$((\$commandExecutionTimeInSeconds / 3600)) 
  ## changing the tab title for konsole with a special echo 
  echo -ne \"\033]30;(\$tabUser-\$tabHost)\007\" 
  ## print the beginning of the prompt (user, host, pwd)
#echo -e \"$colorPwd\" 
  echo -ne \"$NO_COLOR$bgColor$colorUser$colorHost$colorPwd\" 
  ## print the current time with appropriate padding 
  printf \"% \$(( \$COLUMNS - \${exitCodeLength} - \${#USER} - \${#HOSTNAME} - \${#PWD} - 15 ))s\" \"\$(date +%H:%M:%S)\" 
  ## print the exit code string composed before 
  echo -ne \"\$colorExitCode\" 
  ## print the execution time string to the end 
  printf '(%d:%02d:%02d)' \$commandExecutionTimeHours \$commandExecutionTimeMinutes \$commandExecutionTimeSeconds \`$NO_COLOR
> "