#!/usr/bin/env bash

import=$(basename "${BASH_SOURCE[0]}" .sh)
if [[ $(eval echo '$'"${import}") == 0 ]]; then return; fi
eval "${import}=0"

LOG_DIR=/data/shell/log
LOG_LEVEL=INFO

readonly TRUE=0
readonly FALSE=1
readonly NONE=''
readonly NULL='null'
readonly EMPTY_LIST='[]'
