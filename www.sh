#!/bin/bash
set -e

source './lib/letsencrypt-v2.sh'

init_ca_config

accountkey="/tmp/account-key-122222.pem"
ssl_generate_rsa_2048 "${accountkey}"
reg_account "${accountkey}"