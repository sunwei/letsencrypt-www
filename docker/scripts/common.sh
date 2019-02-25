#!/bin/bash

function ensure_bucket_exists() {
  BUCKET_NAME=$1
  qshell listbucket $BUCKET_NAME stdout
}

function download_previous_run_data() {
  BUCKET_NAME=$1
  FILE=$2

  echo "## Checking for previous run data"
  if ! qshell stat $BUCKET_NAME $FILE | grep -q error ; then
    echo "## ACME client data found, downloading and unpacking"

    FILE_SUFFIX="${FILE##*.}"
    FILE_NAME="${FILE%.*}"

    export QN_DOWNLOAD_FILE_NAME=$FILE_NAME
    export QN_DOWNLOAD_FILE_SUFFIX=$FILE_SUFFIX
    envsubst < ./qdownload.conf > ./qn_download.conf

    qshell qdownload 1 ./qn_download.conf
    tar zxvf "$FILE"

  else
    echo "## No ACME client data found. Moving on..."
  fi
}

function run_acme_client(){
  DOMAIN=$1

  echo "## Generating LetsEncrypt certificates for $DOMAIN..."
  dehydrated --config config.prod --register --accept-terms
  dehydrated --config config.prod --domain "$DOMAIN" --cron
}

function upload_data() {
  BUCKET_NAME=$1
  FILE=$2
  echo "## Packaging and uploading certificates to QINIU"
  tar zcvf "$FILE" data
  qshell fput "$BUCKET_NAME" "$FILE" "./${FILE}"
}

function config_qshell_account() {
    qshell account "$QSHELL_ACCESS_KEY" "$QSHELL_SECRET_KEY"
    echo "QShell config done!"
}
