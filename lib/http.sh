#!/bin/bash
set -e

ssl_check_http_dependence() {
  command -v curl > /dev/null 2>&1 || ( echo "> curl required." && exit 1 )
  command -v mktemp > /dev/null 2>&1 || ( echo "> mktemp required." && exit 1 )
}

_http_mk_tmp_file() {
  mktemp "/tmp/letsencrypt-www-http-XXXXXX"
}

_get_curl_version() {
  curl --version | tr -d '\n\r' | awk '{print $2}'
}

_get_letsencrypt_www_version() {
  echo "letsencrypt-www/${LEWWW_VERSION:-0.0.1}"
}

_get_client_agent() {
  "$(_get_letsencrypt_www_version) curl/$(_get_curl_version)"
}

http_get_content_type() {
  local contentType=

  case "${1}" in
    jose) contentType="Content-Type: application/jose+json";;
    *) contentType="Content-Type: application/x-www-form-urlencoded";;
  esac

  echo "${contentType}"
}

_handle_response() {
  local curlRet="${1}" resCode="${2}" reqURI="${3}" reqMethod="${4}"
  if [[ ! "${curlRet}" = "0" ]]; then
    echo "Connection problem: "${reqURI}" with method "${reqMethod}", curl code is "${curlRet}" "
    exit 1
  fi

  if [[ ! "${resCode:0:1}" = 2 ]]; then
    echo "Http problem: "${reqURI}" with method "${reqMethod}", http code is "${resCode}" "
    exit 1
  fi
}

http_head() {
  requestURI="${1}"
  tmpResponse="$(_http_mk_tmp_file)"

  set +e
  resCode="$(curl -4 -A "$(_get_client_agent)" -s -w "%{http_code}" -o "${tmpResponse}" "${requestURI}" -I)"
  curlRet="${?}"
  set -e

  _handle_response "${curlRet}" "${resCode}" "${requestURI}" "HEAD"

  cat "${tmpResponse}"
  rm -rf "${tmpResponse}"
}

http_get() {
  requestURI="${1}"

  tmpHeaders="$(_http_mk_tmp_file)"
  tmpResponse="$(_http_mk_tmp_file)"

  set +e
  resCode="$(curl -4 -A "$(_get_client_agent)" -L -s -w "%{http_code}" -o "${tmpResponse}" "${requestURI}" -D "${tmpHeaders}")"
  curlRet="${?}"
  set -e

  _handle_response "${curlRet}" "${resCode}" "${requestURI}" "GET"

  cat "${tmpResponse}"
  rm -rf "${tmpResponse}"
  rm -rf "${tmpHeaders}"
}

http_post() {
  requestURI="${1}"
  payload="${2}"
  contentType="${3:-Content-Type: application/jose+json}"

  tmpHeaders="$(_http_mk_tmp_file)"
  tmpResponse="$(_http_mk_tmp_file)"

  set +e
  resCode="$(curl -4 -A "$(_get_client_agent)" -L -s -w "%{http_code}" -o "${tmpResponse}" "${requestURI}" -D "${tmpHeaders}" -d "${payload}" -H "${contentType}")"
  curlRet="${?}"
  set -e

  _handle_response "${curlRet}" "${resCode}" "${requestURI}" "POST"

  cat "${tmpResponse}"
  rm -rf "${tmpResponse}"
  rm -rf "${tmpHeaders}"
}