#!/bin/bash
set -e

source "lib/json.sh"
source "lib/formatter.sh"
source "lib/ssl.sh"
source "lib/http.sh"

check_dependence() {
  formatter_check_lib_dependence && ssl_check_lib_dependence && http_check_lib_dependence
}

FQDN=
CERTDIR="./cert"

_CA="https://acme-"${LEWWW_ENV:-staging-}"v02.api.letsencrypt.org/directory"
_CA_URLS=
_CA_ACCOUNT=
_CA_ORDER=

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

new_nonce() {
  http_head $(_get_url_by_name newNonce) | grep -i ^Replay-Nonce: | awk -F ': ' '{print $2}' | rm_new_line
}

get_signed64() {
  local accountRSA="${1}"
  local protected64="${2}"
  local payload64="${3}"

  echo "$(printf '%s' "${protected64}.${payload64}" | ssl_sign_data_with_cert "${accountRSA}" | _urlbase64)"
}

get_data_json() {
  local protected64="${1}"
  local payload64="${2}"
  local signed64="${3}"

  echo '{"protected": "'"${protected64}"'", "payload": "'"${payload64}"'", "signature": "'"${signed64}"'"}'
}

_get_jws() {
  local accountRSA="${1}"

  local pubExponent64="$(printf '%x' "$(ssl_get_rsa_publicExponent "${accountRSA}")" | hex2bin | _urlbase64)"
  local pubMod64="$(ssl_get_rsa_pubMod64 "${accountRSA}" | hex2bin | _urlbase64)"
  local nonce="$(new_nonce)"
  local url="$(_get_url_by_name newAccount)"

  echo '{"alg": "RS256", "jwk": {"e": "'"${pubExponent64}"'", "kty": "RSA", "n": "'"${pubMod64}"'"}, "url": "'"${url}"'", "nonce": "'"${nonce}"'"}'
}

_post_signed_request() {
  local url="${1}"
  local accountRSA="${2}"
  local protected64="${3}"
  local payload64="${4}"

  local signed64=$(get_signed64 "${accountRSA}" "${protected64}" "${payload64}")
  local data=$(get_data_json "${protected64}" "${payload64}" "${signed64}")

  http_post "${url}" "${data}"
}

reg_account() {
  local accountRSA="${1}"
  local url="$(_get_url_by_name newAccount)"

  local payload='{"contact":["mailto:me@sunwei.xyz"], "termsOfServiceAgreed": true}'
  local payload64="$(printf '%s' "${payload}" | _urlbase64)"
  local protected64="$(printf '%s' "$(_get_jws "${accountRSA}")" | _urlbase64)"

  _CA_ACCOUNT="$(_post_signed_request "${url}" "${accountRSA}" "${protected64}" "${payload64}")"
}

_get_account_url() {
  local accountID="$(echo "${_CA_ACCOUNT}" | get_json_int_value id)"
  local newAccountURL="$(_get_url_by_name newAccount)"
  local accountBase=${newAccountURL/new-acct/acct}

  echo "${accountBase}/${accountID}"
}

_get_jwt() {
  local url="${1}"
  local accountURL="$(_get_account_url)"
  local nonce="$(new_nonce)"

  echo '{"alg": "RS256", "kid": "'"${accountURL}"'", "url": "'"${url}"'", "nonce": "'"${nonce}"'"}'
}

new_order() {
  local accountRSA="${1}"
  local url="$(_get_url_by_name newOrder)"

  local payload='{"identifiers": [{"type": "dns", "value": "'"${FQDN}"'"}]}'
  local payload64=$(printf '%s' "${payload}" | _urlbase64)
  local protected64="$(printf '%s' "$(_get_jwt "${url}")" | _urlbase64)"

  _CA_ORDER="$(_post_signed_request "${url}" "${accountRSA}" "${protected64}" "${payload64}")"
}

_get_thumb_print() {
  local accountRSA="${1}"

  local pubExponent64="$(printf '%x' "$(ssl_get_rsa_publicExponent "${accountRSA}")" | hex2bin | _urlbase64)"
  local pubMod64="$(ssl_get_rsa_pubMod64 "${accountRSA}" | hex2bin | _urlbase64)"

  printf '{"e":"%s","kty":"RSA","n":"%s"}' "${pubExponent64}" "${pubMod64}" | ssl_get_data_binary | _urlbase64
}

build_authz() {
  local accountRSA="${1}"

  local orderAuthz="$(echo ${_CA_ORDER} | get_json_array_value authorizations | rm_quotes | rm_space)"
  local response="$(http_get "${orderAuthz}" | clean_json)"
  local identifier="$(echo "${response}" | get_json_dict_value identifier | get_json_string_value value)"
  local challenge="$(echo "${response}" | get_json_array_value challenges | split_arr_mult_value | grep \"dns-01\")"
  local challengeToken="$(echo "${challenge}" | get_json_string_value token)"
  local challengeURL="$(echo "${challenge}" | get_json_string_value url)"
  local thumbPrint="$(_get_thumb_print "${accountRSA}")"

  local keyAuthHook="$(printf '%s' "${challengeToken}.${thumbPrint}" | ssl_get_data_binary | _urlbase64)"

}

main() {
    FQDN="${1}"

    local timestamp="$(date +%s)"

    check_dependence
    init_ca_config

    accountRSA="${CERTDIR}/account-key-${timestamp}.pem"
    ssl_generate_rsa_2048 "${accountRSA}"

    reg_account "${accountRSA}"
    new_order "${accountRSA}"
    build_authz "${accountRSA}"


    echo "${timestamp}"
}

main "${@-}"