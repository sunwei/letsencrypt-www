#!/bin/bash
set -e

source "${LETS_ENCRYPT_WWW_LIB_PATH}/ssl.sh"
source "${LETS_ENCRYPT_WWW_LIB_PATH}/formatter.sh"

urlbase64() {
  ssl_base64_encrypt | clen_base64_url
}