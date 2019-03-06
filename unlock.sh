#!/bin/bash
set -e
BASEDIR="$(dirname "$0")"

SECRETS_DIR=secrets
echo "Checking for encrypted repo content"
if ( file $SECRETS_DIR/* | cut -d: -f2 | grep text &>/dev/null ); then
  echo "Encrypted files detected, unlocking ..."
  git-crypt unlock
else
  echo " Encrypt files not detected."
fi