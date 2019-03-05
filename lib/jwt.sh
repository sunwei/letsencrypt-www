#!/bin/bash
set -e

get_jwt_json() {
  local accountURL="${1}"
  local url="${2}"
  local nonce="${3}"

  echo '{"alg": "RS256", "kid": "'"${accountURL}"'", "url": "'"${url}"'", "nonce": "'"${nonce}"'"}'
}

get_jws_json() {
  local pubExponent64="${1}"
  local pubMod64="${2}"
  local url="${3}"
  local nonce="${4}"

  echo '{"alg": "RS256", "jwk": {"e": "'"${pubExponent64}"'", "kty": "RSA", "n": "'"${pubMod64}"'"}, "url": "'"${url}"'", "nonce": "'"${nonce}"'"}'
}