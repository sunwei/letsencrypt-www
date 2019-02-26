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

check_formatter_lib_dependence() {
  _sed "" < /dev/null > /dev/null 2>&1 || \
   ( echo "> Sed extended (modern) regular expressions required" && exit 1 )
}

rm_new_line() {
  tr -d '\r\n'
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
  rm_new_line | _sed -e 's:=*$::g' -e 'y:+=/:-_~:'
}

hex2bin() {
  # Remove spaces, add leading zero, escape as hex string and parse with printf
  printf -- "$(cat | _sed -e 's/[[:space:]]//g' -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g')"
}