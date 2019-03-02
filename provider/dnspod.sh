#!/bin/bash
set -e

source 'lib/json.sh'
source 'lib/formatter.sh'
source 'lib/http.sh'
source 'lib/domain.sh'
source 'lib/utils.sh'

DNSPod_ID=83717
DNSPod_TOKEN=32ff6aa5112b7bdaf64f48763c4788c4
_LOGIN_TOKEN="${DNSPod_ID},${DNSPod_TOKEN}"
DNSPod_RECORD_ID=
_DOMAIN=
_SUB_DOMAIN=

_get_login_token() {
  echo "${DNSPod_ID},${DNSPod_TOKEN}"
}

_get_res_code() {
  echo "${1}" | get_json_dict_value status | get_json_string_value code
}

_init_domain() {
  local fullDomain="${1}"

  _DOMAIN="$( <<<"${fullDomain}" get_domain )"
  if [[ "$(has_sub_domain "${fullDomain}")" = True ]]; then
    _SUB_DOMAIN="$( get_sub_domain <<<"${fullDomain}" )"
  fi
}

create_txt_record() {
  local fullDomain="${1}" recordValue="${2}"
  local uri="https://dnsapi.cn/Record.Create"
  _init_domain "${fullDomain}"

  local data="login_token=${_LOGIN_TOKEN}&domain=${_DOMAIN}&sub_domain=_acme-challenge.${_SUB_DOMAIN:-}&value=${recordValue}&record_type=TXT&format=json&record_line=默认"
  local res="$(http_post "${uri}" "${data}" "$(http_get_content_type)" | clean_json)"

  if [[ "$(_get_res_code "${res}")" = 1 ]]; then
    DNSPod_RECORD_ID="$(echo "${res}" | get_json_dict_value record | get_json_string_value id )"
    echo "${DNSPod_RECORD_ID}"
  else
    exit_err "${res}"
  fi
}

find_txt_record() {
  local fullDomain="${1}"
  local uri="https://dnsapi.cn/Record.List"
  _init_domain "${fullDomain}"

  local data="login_token=${_LOGIN_TOKEN}&domain=${_DOMAIN}&sub_domain=_acme-challenge.${_SUB_DOMAIN:-}&record_type=TXT&format=json"
  local res="$(http_post "${uri}" "${data}" "$(http_get_content_type)" | clean_json)"
  if [[ "$(_get_res_code "${res}")" = 1 ]]; then
    echo True
  else
    echo False
  fi
}

rm_txt_record() {
  local fullDomain="${1}" recordID="${2}"
  local uri="https://dnsapi.cn/Record.Remove"
  _init_domain "${fullDomain}"

  local data="login_token=${_LOGIN_TOKEN}&domain=${_DOMAIN}&record_id=${recordID}&format=json"
  local res="$(http_post "${uri}" "${data}" "$(http_get_content_type)" | clean_json)"

  if [[ "$(_get_res_code "${res}")" = 1 ]]; then
    echo " + TXT record is clean"
  else
    echo " - TXT record not clean"
  fi
}

HANDLER="${1}"
if [[ "${HANDLER}" =~ ^(create_txt_record|find_txt_record|rm_txt_record)$ ]]; then
  shift
  "$HANDLER" "$@"
fi

