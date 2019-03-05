#!/bin/bash
set -e

source "${LETS_ENCRYPT_WWW_LIB_PATH}/ssl.sh"
source "${LETS_ENCRYPT_WWW_LIB_PATH}/jwt.sh"
source "${LETS_ENCRYPT_WWW_LIB_PATH}/http.sh"
source "${LETS_ENCRYPT_WWW_LIB_PATH}/json.sh"
source "${LETS_ENCRYPT_WWW_LIB_PATH}/utils.sh"
source "${LETS_ENCRYPT_WWW_LIB_PATH}/base64.sh"
source "${LETS_ENCRYPT_WWW_LIB_PATH}/formatter.sh"

_CA="https://acme-"${LEWWW_ENV:-staging-}"v02.api.letsencrypt.org/directory"
_CA_URLS=
_CA_ACCOUNT=
_CA_ACCOUNT_RSA=
_CA_ORDER=

_check_dependence() {
  formatter_check_lib_dependence && ssl_check_lib_dependence && http_check_lib_dependence
}

_lev2_new_account() {
  _CA_ACCOUNT_RSA="${CERTDIR}/account-key-${timestamp}.pem"
  ssl_generate_rsa_2048 "${_CA_ACCOUNT_RSA}"
}

_get_new_account_url() {
  echo "$(get_json_url_by_name newAccount)"
}

_get_account_pubExponent() {
  printf '%x' "$(ssl_get_rsa_publicExponent "${_CA_ACCOUNT_RSA}")"
}

_get_account_pubExponent64() {
  _get_account_pubExponent | hex2bin | urlbase64
}

_get_account_pubMod() {
  ssl_get_rsa_pubMod64 "${_CA_ACCOUNT_RSA}"
}

_get_account_pubMod64() {
  _get_account_pubMod | hex2bin | _urlbase64
}

_get_signed64() {
  local protected64="${1}"
  local payload64="${2}"

  echo "$(printf '%s' "${protected64}.${payload64}" | ssl_sign_data_with_cert "${_CA_ACCOUNT_RSA}" | urlbase64)"
}

_get_data_json() {
  local protected64="${1}"
  local payload64="${2}"
  local signed64="${3}"

  echo '{"protected": "'"${protected64}"'", "payload": "'"${payload64}"'", "signature": "'"${signed64}"'"}'
}

_get_account_url() {
  local accountID="$(echo "${_CA_ACCOUNT}" | get_json_int_value id)"
  local newAccountURL="$(_get_new_account_url)"
  local accountBase=${newAccountURL/new-acct/acct}

  echo "${accountBase}/${accountID}"
}

_get_rsa_pub_exponent64() {
  local accountRSA="${1}"
  printf '%x' "$(ssl_get_rsa_publicExponent "${accountRSA}")" | hex2bin | _urlbase64
}

_get_rsa_pub_mode64() {
  local accountRSA="${1}"
  ssl_get_rsa_pubMod64 "${accountRSA}" | hex2bin | _urlbase64
}

_post_signed_request() {
  local url="${1}"
  local protected64="${2}"
  local payload64="${3}"

  local signed64=$(_get_signed64 "${protected64}" "${payload64}")
  local data=$(_get_data_json "${protected64}" "${payload64}" "${signed64}")

  http_post "${url}" "${data}"
}

lev2_new_nonce() {
  http_head $(get_json_url_by_name newNonce) | grep -i ^Replay-Nonce: | awk -F ': ' '{print $2}' | rm_new_line
}

_get_jws() {
  local pubExponent64="$(_get_account_pubExponent64)"
  local pubMod64="$(_get_account_pubMod64)"
  local url="$(_get_new_account_url)"
  local nonce="$(lev2_new_nonce)"

  get_jws_json "${pubExponent64}" "${pubMod64}" "${url}" "${nonce}"
}

lev2_reg_account() {
  local url="$(_get_new_account_url)"

  local payload='{"contact":["mailto:me@sunwei.xyz"], "termsOfServiceAgreed": true}'
  local payload64="$(printf '%s' "${payload}" | urlbase64)"
  local protected64="$(printf '%s' "$(_get_jws)" | urlbase64)"

  _CA_ACCOUNT="$(_post_signed_request "${url}" "${_CA_ACCOUNT_RSA}" "${protected64}" "${payload64}")"
}

_get_jwt() {
  local url="${1}"
  local accountURL="$(_get_account_url)"
  local nonce="$(lev2_new_nonce)"

  get_jwt_json "${accountURL}" "${url}" "${nonce}"
}

_get_new_order_url() {
  echo "$(get_json_url_by_name newOrder)"
}

lev2_new_order() {
  local FQDN="${1}"
  local url="$(_get_new_order_url)"

  local payload='{"identifiers": [{"type": "dns", "value": "'"${FQDN}"'"}]}'
  local payload64=$(printf '%s' "${payload}" | urlbase64)
  local protected64="$(printf '%s' "$(_get_jwt "${url}")" | urlbase64)"

  _CA_ORDER="$(_post_signed_request "${url}" "${accountRSA}" "${protected64}" "${payload64}")"
}

lev2_init() {
  _check_dependence
  _lev2_new_account

  _CA_URLS=$(http_get "${_CA}")
}