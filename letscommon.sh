#!/bin/bash
set -e

_exiterr() {
  echo "ERROR: ${1}" >&2
  exit 1
}

get_json_int_value() {
  local filter
  filter=$(printf 's/.*"%s": *\([0-9]*\).*/\\1/p' "$1")
  sed -n "${filter}"
}

# Get array value from json dictionary
get_json_array_value() {
  local filter
  filter=$(printf 's/.*"%s": *\\[\([^]]*\)\\].*/\\1/p' "$1")
  sed -n "${filter}"
}

# Get string value from json dictionary
get_json_string_value() {
  local filter
  filter=$(printf 's/.*"%s": *"\([^"]*\)".*/\\1/p' "$1")
  sed -n "${filter}"
}

# Get sub-dictionary from json
get_json_dict_value() {
  local filter
  filter=$(printf 's/.*"%s": *{\([^}]*\)}.*/\\1/p' "$1")
  sed -n "${filter}"
}

# Encode data as url-safe formatted base64
urlbase64() {
  # urlbase64: base64 encoded string with '+' replaced with '-' and '/' replaced with '_'
  openssl base64 -e | tr -d '\n\r' | sed -E -e 's:=*$::g' -e 'y:+/:-_:'
}

# Convert hex string to binary data
hex2bin() {
  # Remove spaces, add leading zero, escape as hex string and parse with printf
  printf -- "$(cat | sed -E -e 's/[[:space:]]//g' -e 's/^(.(.{2})*)$/0\1/' -e 's/(.{2})/\\x\1/g')"
}

_mktemp() {
  # shellcheck disable=SC2068
  mktemp ${@:-} "/tmp/letsencrypt-XXXXXX"
}

# Remove newlines and whitespace from json
clean_json() {
  tr -d '\r\n' | sed -E -e 's/ +/ /g' -e 's/\{ /{/g' -e 's/ \}/}/g' -e 's/\[ /[/g' -e 's/ \]/]/g'
}


http_request() {
    tempCont="$(_mktemp)"
    tempHeaders="$(_mktemp)"
    ipVersion=4

    httpMethod="${1}"
    requestURI="${2}"
    payloadData="${3:-}"
    echo "${payloadData}" >&2
    responseCode=

    set +e
    if [[ "HEAD" = "${httpMethod}" ]]; then
        responseCode="$(curl -4 -A "letsencrypt/0.0.1 curl/7.54.0" -s -w "%{http_code}" -o "${tempCont}" "${requestURI}" -I)"
        curlRet="${?}"
    elif [[ "${1}" = "POST" ]]; then
        responseCode="$(curl -4 -A "letsencrypt/0.0.1 curl/7.54.0"  -s -w "%{http_code}" -o "${tempCont}" "${requestURI}" -D "${tempHeaders}" -H 'Content-Type: application/jose+json' -d "${payloadData}")"
        cat "${tempCont}" >&2
        curlRet="${?}"
    fi
    set -e

    if [[ ! "${curlRet}" = "0" ]]; then
        _exiterr "Connection problem to server "${requestURI}" with method "${httpMethod}", curl response code is "${curlRet}" "
    fi

    if [[ ! "${responseCode:0:1}" = 2 ]]; then
        _exiterr "Http request error to URI "${requestURI}" with method "${httpMethod}", http response code is "${responseCode}" "
    fi

    cat "${tempCont}"
    rm -rf "${tempCont}"
    rm -rf "${tempHeaders}"
}