#!/bin/bash
set -e

source 'lib/formatter.sh'
source 'lib/ssl.sh'

#printf '%x' 65537 | hex2bin | url

printf '%x' 65537 | printf -- "$(cat | sed -E -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g')" | openssl base64 -e
printf '%x' 65537 | cat | sed -E -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g' | openssl base64 -e
printf '%x' 65537 | printf -- "$(cat | sed -E -e 's/[[:space:]]//g' -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g')" | openssl base64 -e


echo "abc" | ssl_sign_data_with_cert "/tmp/letsencrypt-www-account-key" | ssl_base64_encrypt

