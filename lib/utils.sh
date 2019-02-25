#!/bin/bash
set -e

mk_tmp_file() {
  mktemp "/tmp/letsencrypt-www-XXXXXX"
}

exit_err() {
  echo "ERROR: ${1}" >&2
  exit 1
}