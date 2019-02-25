#!/bin/bash
set -e

rm_json_ws() {
  tr -d '\r\n' | sed -E -e 's/ +/ /g' \
  -e 's/\: /:/g' \
  -e 's/\, /,/g' \
  -e 's/\{ /{/g' \
  -e 's/ \}/}/g' \
  -e 's/\[ /[/g' \
  -e 's/ \]/]/g'
}


urlbase64() {
  openssl base64 -e | tr -d '\n\r' | sed -E -e 's:=*$::g' -e 'y:+=/:-_~:'
}

url() {
  openssl base64 -e
}

hex2bin() {
  # Remove spaces, add leading zero, escape as hex string and parse with printf
  printf -- "$(cat | sed -E -e 's/[[:space:]]//g' -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g')"
}