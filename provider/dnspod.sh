#!/bin/bash
set -e

source '../lib/json.sh'

DNSPod_ID=83717
DNSPod_TOKEN=32ff6aa5112b7bdaf64f48763c4788c4

_get_login_token() {
  echo "${DNSPod_ID}.${DNSPod_TOKEN}"
}

create_txt_record() {
  local domain="${1}" challengeToken="${2}" recordValue="${3}"

  local loginToken="$(_get_login_token)"
  local uri="https://dnsapi.cn/Record.Create"
  local data="login_token=${loginToken}&format=json&domain=${domain}&sub_domain=_acme-challenge.abcd&record_type=TXT&value=${TOKEN_VALUE}&record_line=默认"

  data='{"login_token": "'"${loginToken}"'", "record_type": "'"${recordType}"'", "value": "'"${TOKEN_VALUE}"'", "domain": "sunzhongmou.com", "sub_domain": "_acme-challenge.abcd", "format": "json", "record_line": "默认"}'
  curl -X POST https://dnsapi.cn/Record.Create -d "login_token=83717,32ff6aa5112b7bdaf64f48763c4788c4&format=json&domain=sunzhongmou.com&sub_domain=_acme-challenge.abcd&record_type=TXT&value=${TOKEN_VALUE}&record_line=默认"

}

get_txt_record() {
  :
}

rm_txt_record() {
  :
}

HANDLER="${1}"
if [[ "${HANDLER}" =~ ^(create_txt_record|get_txt_record|rm_txt_record)$ ]]; then
  shift
  "$HANDLER" "$@"
fi

