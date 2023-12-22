#!/usr/bin/env bash

import=$(basename "${BASH_SOURCE[0]}" .sh)
if [[ $(eval echo '$'"${import}") == 0 ]]; then return; fi
eval "${import}=0"

source /data/shell/shell-log/test_config.sh
source /data/shell/shell-log/test_log.sh

function _NotNull(){
	local param=$1;local err_msg=$2
	err_msg=${err_msg:-'传入的参数空'}
	[[ -z $param ]] && info_log "${err_msg}" || return "${TRUE}"
}

function _Numeric(){
        local param=$1;local err_msg=$2
        err_msg=${err_msg:-'传入的参数不是纯数字'}
        ! grep -q '^[[:digit:]]*$' <<< ${param} && info_log "${err_msg}" || return "${TRUE}"
}

function _Min(){
	_NotNull $1; _NotNull $2; err_msg=$3
	err_msg=${err_msg:-"参数 $1 小于 参数 $2"}
	[[ $2 -gt $1 ]] && info_log "${err_msg}" || return "${TRUE}"
}

function _Max(){
        _NotNull $1; _NotNull $2; err_msg=$3
        err_msg=${err_msg:-"参数 $1 大于 参数 $2"}
        [[ $2 -lt $1 ]] && info_log "${err_msg}" || return "${TRUE}"
}
