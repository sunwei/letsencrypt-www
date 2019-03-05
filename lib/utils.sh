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

check_fd_3() {
  if { true >&3; } 2>/dev/null; then
      : # fd 3 looks OK
  else
      exit_err "_check_fd_3: FD 3 not open"
  fi
}