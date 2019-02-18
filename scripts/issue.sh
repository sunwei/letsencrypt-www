#!/bin/bash
set -e
source common.sh

: "${FQDN:?Please set the FQDN associated with the certificate to be issued.}"

config_qshell_account

ensure_bucket_exists "$QSHELL_BUCKET_NAME"
download_previous_run_data "$QSHELL_BUCKET_NAME" "$FQDN"-keys.tgz
run_acme_client "$FQDN"
upload_data "$QSHELL_BUCKET_NAME" "$FQDN"-keys.tgz
