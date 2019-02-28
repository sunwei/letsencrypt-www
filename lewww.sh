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
  local accountRSA="${1}"

  local pubExponent64="$(printf '%x' "$(ssl_get_rsa_publicExponent "${accountRSA}")" | hex2bin | _urlbase64)"
  local pubMod64="$(ssl_get_rsa_pubMod64 "${accountRSA}" | hex2bin | _urlbase64)"
  local nonce="$(new_nonce)"
  local url="$(_get_url_by_name newAccount)"

  echo '{"alg": "RS256", "jwk": {"e": "'"${pubExponent64}"'", "kty": "RSA", "n": "'"${pubMod64}"'"}, "url": "'"${url}"'", "nonce": "'"${nonce}"'"}'
}

_get_jwt() {
  local accountURL="${1}"
  local url="${2}"
  local nonce="${3}"

  echo '{"alg": "RS256", "kid": "'"${accountURL}"'", "url": "'"${url}"'", "nonce": "'"${nonce}"'"}'
}

new_nonce() {
  http_head $(_get_url_by_name newNonce) | grep -i ^Replay-Nonce: | awk -F ': ' '{print $2}' | rm_new_line
}

generate_payload() {
  local email="${1}"

  echo '{"contact":["mailto:'"${email}"'"], "termsOfServiceAgreed": true}'
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

reg_account() {
  local accountRSA="${1}"

  local protected64="$(printf '%s' "$(_get_jws "${accountRSA}")" | _urlbase64)"
  local payload64="$(printf '%s' "$(generate_payload me@sunwei.xyz)" | _urlbase64)"

  local signed64=$(get_signed64 "${accountRSA}" "${protected64}" "${payload64}")
  local data=$(get_data_json "${protected64}" "${payload64}" "${signed64}")

  echo "$(http_post "$(_get_url_by_name newAccount)" "${data}")"
}

main() {
    FQDN="${1}"

    local timestamp="$(date +%s)"

    check_dependence
    init_ca_config

    accountRSA="${CERTDIR}/account-key-${timestamp}.pem"

    ssl_generate_rsa_2048 "${accountRSA}"
    reg_account "${accountRSA}"

    echo "${timestamp}"
}

main "${@-}"