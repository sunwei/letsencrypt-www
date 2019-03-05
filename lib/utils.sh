#!/bin/bash
set -e

mk_tmp_file() {
  mktemp "/tmp/letsencrypt-www-XXXXXX"
}

exit_err() {
  echo "ERROR: ${1}" >&2
  exit 1
}

check_msg() {
  printf "\xE2\x9C\x94 ${1}\n"
}

get_timestamp() {
  echo "$(date +%s)"
}