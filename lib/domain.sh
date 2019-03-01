#!/bin/bash
set -e

_has_sub_domain() {
  local domain="${1}"
  local dotCount="$(echo "${domain}" | grep -o '\.' | wc -l)"

  if [[ "${dotCount}" -gt 1 ]]; then
    echo True
  fi
  echo False
}

get_sub_domain() {
  if [[ "$(_has_sub_domain)" = True ]]; then
    echo "${1}" | cut -d'.' -f1
  else
    echo ""
  fi
}

get_domain() {
#maindomain=${subdomain#*.}
#sed -r 's/.*\.([^.]+\.[^.]+)$/\1/'

  if [[ "$(_has_sub_domain)" = True ]]; then
    echo "${1}" | sed -E -e 's/^\w+\..*//'
#    sed 's/.*\.\(.*\..*\)/\1/'
  else
    echo "${1}"
  fi
}
