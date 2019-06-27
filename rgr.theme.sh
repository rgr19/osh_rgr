#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=" ${red}@"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}#"
SCM_THEME_PROMPT_PREFIX="{"
SCM_THEME_PROMPT_SUFFIX="${green}}"

GIT_THEME_PROMPT_DIRTY=" ${red}D"
GIT_THEME_PROMPT_CLEAN=" ${green}C"
GIT_THEME_PROMPT_PREFIX="${bold_black}["
GIT_THEME_PROMPT_SUFFIX="${bold_black}]"



CONDAENV_THEME_PROMPT_SUFFIX="|"

# IP address
IP_ENABLED=1
IP_SEPARATOR='| '
DEFAULT_COLOR="${bold_white}"



function get_ip_info {
	#local myip=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
    	#local addr=$(ips | sed -e :a -e '$!N;s/\n/${IP_SEPARATOR}/;ta' | sed -e 's/127\.0\.0\.1\${IP_SEPARATOR}//g')
    	#local addrs=$(echo $addr | grep -Eo '[0-9\.]+' && echo ${myip})
	local LANIFACE=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')
	local ADDR=$(ip addr show $LANIFACE | grep -w inet | cut -d '/' -f1 | grep -Eo -m 1 '[0-9\.]+' | head -1)
	echo "$LANIFACE: $ADDR"
}


# Displays ip prompt 
function ip_prompt_info() {
    if [[ $IP_ENABLED == 1 ]]; then
        echo -e "${bold_black}$(get_ip_info)"
    fi
}


function get_jobs() {
	local jobs=$(jobs | wc -l | xargs)
	echo -e "${bold_black}$jobs"
}

function get_jobs_pids() {
	local pids=$(jobs -p)
	echo -e "${bold_black}"$pids

}

function calc_perm() {
  p="$1"
  n=0
  [[ $p =~ .*r.* ]] && (( n+=4 ))
  [[ $p =~ .*w.* ]] && (( n+=2 ))
  [[ $p =~ .*x.* ]] && (( n+=1 ))
  printf $n

}

function get_dir_perm_own() {
	local info=$(ls -ld . | cut -d' ' -f 1,3,4)
	local rp=$(calc_perm $(echo $info | cut -c2-4))
	local up=$(calc_perm $(echo $info | cut -c5-7))
	local op=$(calc_perm $(echo $info | cut -c8-10))
	echo -e "${bold_black}.:$rp$up$op"
}

function dulcie_background() {
  echo -en "\[\e[48;5;${1}m\]"
}

function colorize() {


    #!/bin/bash

    if [ "$1" == "--help" ] ; then
        echo "Executes a command and colorizes all errors occured"
        echo "Example: `basename ${0}` wget ..."
        echo "(c) o_O Tync, ICQ# 1227-700, Enjoy!"
        exit 0
        fi

    # Temp file to catch all errors
    TMP_ERRS=$(mktemp)

    # Execute command
    "$@" 2> >(while read line; do echo -e "\e[01;31m$line\e[0m" | tee --append $TMP_ERRS; done)
    EXIT_CODE=$?

    # Display all errors again
    if [ -s "$TMP_ERRS" ] ; then
        echo -e "\n\n\n\e[01;31m === ERRORS === \e[0m"
        cat $TMP_ERRS
        fi
    rm -f $TMP_ERRS

    # Finish
    exit $EXIT_CODE
}


function prompt_command() {

  local RC="$?"

  # Set return status color
  if [[ ${RC} == 0 ]]; then
      ret_status="${bold_green}"
    else
      ret_status="${bold_red}"
    fi

    # Append new history lines to history file
    history -a

    local uh="${bold_green}[\u@${bold_green}\h${bold_white}:"
#	echo PPID=$PPID
#	if [ "$PPID" == "1" ]; then
	#	local dir="${bold_white}\w"
#	else
#	local dir="${black}file://${bold_white}${PWD}"
#	fi

	local dir="${bold_white}${PWD}"
  local LL0=""
	local repo="$(scm_prompt_info)"
  local py="${bold_black}($(python_version_prompt))"
  if [ -z "$repo" ]; then
    LL0="${py}"
  else
   LL0="${repo}  ${py}"
  fi

	local clock="${bold_black}[\A]"
	local LL0="${bold_cyan}┌${LL0}  $(ip_prompt_info)  $(get_dir_perm_own)  %:$(get_jobs) |$(get_jobs_pids)|"
  local LL1="${bold_cyan}├${uh} ${dir}  ${ret_status}?:${RC}  ${bold_black} t:${EXEC_TIME}  "


	local prompt="${bold_black} >>> \$ "
	local LL2="${bold_cyan}└${clock}${prompt}"

  PS1="\n${LL0}\n${LL1}\n${LL2}${bold_blue}"


}


safe_append_prompt_command prompt_command




