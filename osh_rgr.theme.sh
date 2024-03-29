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

 # not always working

 if ! (timeout 0.3 nc 1.1.1.1 53 -zv > /dev/null 2>&1); then 
	echo "offline"; 
 else
	timeout 0.3 python $DIR/check_network.py
 fi
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

	export EXIT_STATUS=$?
	local RC="${EXIT_STATUS}"

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

	local prompt="${bold_black} >>> λ "

	if [ ! -z "$DISABLE_EXTRA" ]; then

		PS1="${prompt}${cyan}"

	else 

		local dir="${bold_white}${PWD}"
		local repo="$(scm_prompt_info)"
		local py="${bold_black}($(python_version_prompt))"
		local ip="$(ip_prompt_info)"
    local LL0=""
		if [ -z "$repo" ]; then
			LL0="${py}"
		else
			LL0="${repo}  ${py}"
		fi

		local clock="${bold_black}[\A]"
		local LL0="${bold_cyan}┌${LL0}  ${ip} $(get_dir_perm_own)  %:$(get_jobs) |$(get_jobs_pids)|"
		local LL1="${bold_cyan}├${uh} ${dir}  ${ret_status}?:${RC} $:\$  ${bold_black} "
		local LL2="${bold_cyan}└${clock}${prompt}"

		PS1="${LL0}\n${LL1}\n${LL2}${blue}"
	fi
}


safe_append_prompt_command prompt_command

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $DIR/.bash-preexec.sh || true

alias clearBashLogs='/bin/rm $HOME/var/log/bash_history/* -Rf'

if [ -z "${WITH_LOGGING}" ]; then 
	unset preexec
	unset precmd 
fi 

function logit {
	local RC=$EXIT_STATUS
	if [ -z "$DISABLE_EXTRA" ]; then 
		python $DIR/logger.py "$@"
	else
		python $DIR/logger.py "$@" > /dev/null 2>&1 
	fi
	export EXIT_STATUS=$RC
}

preexec() {
	local WHERE
	if [ -z "$DISABLE_EXTRA" ]; then 
		WHERE="both"
	else
		WHERE="file"
	fi


	unset ANY_STDIN
	if [ ! -z "$@" ]; then
		logit -w $WHERE -i "\$ BEGIN[?] $@"
		export ANY_STDIN=$@
		if [ -z "$DISABLE_EXTRA" ]; then 
			echo ">>>"
		fi
	fi

}

precmd() { 

	local WHERE
	if [ -z "$DISABLE_EXTRA" ]; then 
		WHERE="both"
	else
		WHERE="file"
	fi

	if [ ! -z "${ANY_STDIN}" ]; then
		if [ -z "$DISABLE_EXTRA" ]; then 
			echo "<<<"
		fi
		logit -w "$WHERE" -x $EXIT_STATUS -i "\$ END[${EXIT_STATUS}] ${ANY_STDIN}"
	fi
	unset ANY_STDIN
}






