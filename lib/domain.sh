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

domain_check_lib_dependence() {
  _sed "" < /dev/null > /dev/null 2>&1 || \
   ( echo "> Sed extended (modern) regular expressions required" && exit 1 )
}

has_sub_domain() {
  local domain="${1}"
  local dotCount="$(echo "${domain}" | grep -o '\.' | wc -l)"

  if [[ "${dotCount}" -gt 1 ]]; then
    echo True
  else
    echo False
  fi
}

get_sub_domain() {
  _sed -e 's/(.*)\.([^.]+\.[^.]+)$/\1/'
}

get_domain() {
  _sed -e 's/.*\.([^.]+\.[^.]+)$/\1/'
}
