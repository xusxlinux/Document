#!/usr/bin/env bash

import=$(basename "${BASH_SOURCE[0]}" .sh)
if [[ $(eval echo '$'"${import}") == 0 ]]; then return; fi
eval "${import}=0"

if [[ ! -d $LOG_DIR ]];then
  mkdir -p $LOG_DIR
fi

case ${LOG_LEVEL} in
	"ERROR")  log_level=0  ;;
	"WARN" )  log_level=1  ;;
	"INFO" )  log_level=2  ;;
	"DEBUG")  log_level=3  ;;
esac


function error_log(){
        if [[ $log_level -ge 0  ]];then
		echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: [error] $1" >> $LOG_DIR/error.log 2>&1
        fi
}
function warn_log(){
        if [ $log_level -ge 1  ];then
		echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: [wran] $1" >> $LOG_DIR/warn.log 2>&1
        fi
}
function info_log(){
        if [[ $log_level -ge 2 ]];then
		echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: [info] $1" >> $LOG_DIR/info.log 2>&1
        fi
}
function debug_log(){
        if [ $log_level -ge 3  ];then
		echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: [debug] $1" >> $LOG_DIR/debug.log 2>&1
        fi
}
