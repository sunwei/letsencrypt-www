#!/bin/bash
set -e

get_json_int_value() {
  sed -n "$(printf 's/.*"%s": *\([0-9]*\).*/\\1/p' "$1")"
}

get_json_string_value() {
  sed -n "$(printf 's/.*"%s": *"\([^"]*\)".*/\\1/p' "$1")"
}

get_json_array_value() {
  sed -n "$(printf 's/.*"%s": *\\[\([^]]*\)\\].*/\\1/p' "$1")"
}

get_json_dict_value() {
  sed -n "$(printf 's/.*"%s": *{\([^}]*\)}.*/\\1/p' "$1")"
}

get_json_url_by_name() {
  local json="${1}"
  local urlName="${2}"
  echo "${json}" | get_json_string_value "${urlName}"
}