#!/bin/bash
set -e

OS_TYPE="$(uname)"
_sed() {
  if [[ "${OS_TYPE}" = "Linux" || "${OS_TYPE:0:5}" = "MINGW" ]]; then
    sed -r "${@}"
  else
    sed -E "${@}"
  fi
}

formatter_check_lib_dependence() {
  _sed "" < /dev/null > /dev/null 2>&1 || \
   ( echo "> Sed extended (modern) regular expressions required" && exit 1 )
}

rm_new_line() {
  tr -d '\n\r'
}

clean_json() {
  rm_new_line | \
  _sed -e 's/ +/ /g' \
  -e 's/\: /:/g' \
  -e 's/\, /,/g' \
  -e 's/\{ /{/g' \
  -e 's/ \}/}/g' \
  -e 's/\[ /[/g' \
  -e 's/ \]/]/g'
}

clen_base64_url() {
  rm_new_line | _sed -e 's:=*$::g' -e 'y:+/:-_:'
}

_rm_space() {
  _sed -e 's/[[:space:]]//g'
}

_ensure_digital() {
  _sed -e 's/^(.(.{2})*)$/0\1/'
}

_convert_to_hex() {
  _sed -e 's/(.{2})/\\x\1/g'
}

hex2bin() {
  printf -- "$(cat | _rm_space | _ensure_digital | _convert_to_hex)"
}