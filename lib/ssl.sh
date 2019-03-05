#!/bin/bash
set -e

ssl_check_lib_dependence() {
  openssl version > /dev/null 2>&1 || ( echo "> openssl required." && exit 1 )
}

ssl_get_location() {
  openssl version -d | cut -d\" -f2
}

ssl_get_conf() {
  local sslPWD="$(ssl_get_location)"
  echo "${sslPWD}/openssl.cnf"
}

ssl_base64_encrypt() {
  openssl base64 -e
}

ssl_generate_rsa_2048() {
  openssl genrsa -out "${1}" 2048
}

ssl_generate_subject_with_domain() {
  printf "/CN=%s/" ${1}
}

ssl_generate_san_with_domain() {
  printf "[SAN]\nsubjectAltName=DNS:%s" ${1}
}

ssl_print_in_text_form() {
  openssl x509 -text
}

ssl_get_rsa_publicExponent() {
  openssl rsa -in "${1}" -noout -text | awk '/publicExponent/ {print $2}'
}

ssl_get_rsa_pubMod64() {
  openssl rsa -in "${1}" -noout -modulus | cut -d'=' -f2
}

ssl_sign_data_with_cert() {
  openssl dgst -sha256 -sign "${1}"
}

ssl_get_data_binary() {
  openssl dgst -sha256 -binary
}

ssl_generate_config() {
  :
}

ssl_convert_csr_der() {
  openssl req -outform DER
}

ssl_generate_csr() {
  openssl req -new -sha256 -key "${1}" -out "${2}"
}

ssl_generate_san_csr() {
  local priKey="${1}" csr="${2}" domain="${3}"
  local subj="$(ssl_generate_subject_with_domain ${domain})"
  local san="$(ssl_generate_san_with_domain ${domain})"

  local tmpSSLCnf="$(mktemp "/tmp/letsencrypt-www-san-XXXXXX")" #TODO REMOVE
  cat "$(ssl_get_conf)" > "${tmpSSLCnf}"
  echo "${san}" >> "${tmpSSLCnf}"

  openssl req -new -sha256 -key "${priKey}" -out "${csr}" -subj "${subj}" -reqexts SAN -config "${tmpSSLCnf}"
}