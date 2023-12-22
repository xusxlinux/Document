#!/usr/bin/env bash

source /data/shell/shell-log/test_action_02.sh

LATEST_FD_INDEX=3
function available_fd(){
  [[ $((LATEST_FD_INDEX++)) -eq 255 ]] && log_fail "In the process of a largest open file descriptors is 255" || return ${LATEST_FD_INDEX}
}


function new_threadPool(){
	_Numeric "$1" && _NotNull "$1" && _Min "0" "$1"

	available_fd
	local FD=$?

	local coreSize=$1
	local threadPoolName="fifo"
	[[ -e "${threadPoolName}" ]] || mkfifo "${threadPoolName}"
	eval "exec ${FD}<>${threadPoolName} && rm -rf ${threadPoolName}"
	for ((i=0;i<coreSize;i++));do echo "${i}" >&"${FD}";done
	submit_threadPool "$FD"
	return "${FD}"
}

function submit_threadPool(){
	local FD=$1
	for a in {1..10};
	do
		read -r -u"${FD}"
		{
		  echo $a
		  sleep 1
		  echo "${coreSize}" >& "${FD}"
		}&
	done
	wait
	eval "exec ${FD}>&-"
}
