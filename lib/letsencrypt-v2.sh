#!/bin/bash
set -e

BASE_DIR=$(dirname $0)

source "json.sh"
source "formatter.sh"
source "ssl.sh"
source "http.sh"

formatter_check_lib_dependence && ssl_check_lib_dependence && http_check_lib_dependence

_CA="https://acme-"${LEWWW_ENV:-staging-}"v02.api.letsencrypt.org/directory"
_CA_URLS=

init_ca_config() {
  _CA_URLS=$(http_get "${_CA}")
}

_urlbase64() {
  ssl_base64_encrypt | clen_base64_url
}

_get_url_by_name() {
  local urlName="${1}"
  echo "${_CA_URLS}" | clean_json | get_json_string_value "${urlName}"
}

_get_rsa_pub_exponent64() {
  local accountRSA="${1}"
  printf '%x' "$(ssl_get_rsa_publicExponent "${accountRSA}")" | hex2bin | _urlbase64
}

_get_rsa_pub_mode64() {
  local accountRSA="${1}"
  ssl_get_rsa_pubMod64 "${accountRSA}" | hex2bin | _urlbase64
}

_get_jws() {
  local pubExponent64="${1}"
  local pubMod64="${2}"
  local url="${3}"
  local nonce="${4}"

  echo '{"alg": "RS256", "jwk": {"e": "'"${pubExponent64}"'", "kty": "RSA", "n": "'"${pubMod64}"'"}, "url": "'"${url}"'", "nonce": "'"${nonce}"'"}'
}

new_nonce() {
  http_head $(_get_url_by_name newNonce) | grep -i ^Replay-Nonce: | awk -F ': ' '{print $2}' | rm_new_line
}

generate_payload() {
  local email="${1}"

  echo '{"contact":["mailto:'"${email}"'"], "termsOfServiceAgreed": true}'
}

reg_account() {
  local accountRSA="${1}"
  local pubExponent64="$(printf '%x' "$(ssl_get_rsa_publicExponent "${accountRSA}")" | hex2bin | _urlbase64)"
  local pubMod64="$(ssl_get_rsa_pubMod64 "${accountRSA}" | hex2bin | _urlbase64)"
  local nonce="$(new_nonce)"

  local protected64="$(printf '%s' "$(_get_jws "${pubExponent64}" "${pubMod64}" "$(_get_url_by_name newAccount)" "${nonce}")" | _urlbase64)"
  local payload64="$(printf '%s' "$(generate_payload me@sunwei.xyz)" | _urlbase64)"


  local signed64="$(printf '%s' "${protected64}.${payload64}" | ssl_sign_data_with_cert "${accountRSA}" | _urlbase64)"
  local data='{"protected": "'"${protected64}"'", "payload": "'"${payload64}"'", "signature": "'"${signed64}"'"}'

  echo "$(http_post "$(_get_url_by_name newAccount)" "${data}")"
}

init_ca_config

accountkey="/tmp/account-key-122222.pem"
#ssl_generate_rsa_2048 "${accountkey}"
reg_account "${accountkey}"

#
#reg_account() {
#
#    signed64="$(printf '%s' "${protected64}.${payload64}" | openssl dgst -sha256 -sign "${accountKey}" | urlbase64)"
#    data='{"protected": "'"${protected64}"'", "payload": "'"${payload64}"'", "signature": "'"${signed64}"'"}'
#
#    http_request POST "${CA_NEW_ACCOUNT}" "${data}" > "${ACCOUNT_KEY_JSON}"
#
#    if [[ -e "${ACCOUNT_KEY_JSON}" ]]; then
#        ACCOUNT_ID="$(cat "${ACCOUNT_KEY_JSON}" | get_json_int_value id)"
#        CA_ACCOUNT=${CA_NEW_ACCOUNT/new-acct/acct}
#        ACCOUNT_URL="${CA_ACCOUNT}/${ACCOUNT_ID}"
#    fi
#
#
#}