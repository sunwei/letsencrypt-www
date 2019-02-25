#!/bin/bash
set -e

get_json_int_value() {
  local filter
  filter=$(printf 's/.*"%s": *\([0-9]*\).*/\\1/p' "$1")
  sed -n "${filter}"
}

get_json_string_value() {
  local filter
  filter=$(printf 's/.*"%s": *"\([^"]*\)".*/\\1/p' "$1")
  sed -n "${filter}"
}

get_json_array_value() {
  local filter
  filter=$(printf 's/.*"%s": *\\[\([^]]*\)\\].*/\\1/p' "$1")
  sed -n "${filter}"
}

get_json_dict_value() {
  local filter
  filter=$(printf 's/.*"%s": *{\([^}]*\)}.*/\\1/p' "$1")
  sed -n "${filter}"
}

rm_json_ws() {
  tr -d '\r\n' | sed -E -e 's/ +/ /g' \
  -e 's/\: /:/g' \
  -e 's/\, /,/g' \
  -e 's/\{ /{/g' \
  -e 's/ \}/}/g' \
  -e 's/\[ /[/g' \
  -e 's/ \]/]/g'
}
