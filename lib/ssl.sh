#!/bin/bash
set -e

ssl_check_lib_dependence() {
  openssl version > /dev/null 2>&1 || ( echo "> openssl required." && exit 1 )
}

ssl_get_location() {
  openssl version -d | cut -d\" -f2
}

ssl_base64_encrypt() {
  openssl base64 -e
}

ssl_generate_rsa_2048() {
  openssl genrsa -out "${1}" 2048
}

ssl_print_in_text_form() {
  openssl x509 -text
}

add_config_to_csr() {
  <<<"${1}" openssl req -config "${2}"
}

add_sub_to_csr() {
  <<<"${1}" openssl req -subj "${2}"
}

generate_csr() {
  openssl req -new -sha256 -key "${1}" -out "${2}" -reqexts SAN
}

generate_csr_der() {
  <<<"${1}" openssl req -outform DER
}

get_rsa_publicExponent() {
  openssl rsa -in "${1}" -noout -text | awk '/publicExponent/ {print $2}'
}

get_rsa_pubMod64() {
  openssl rsa -in "${1}" -noout -modulus | cut -d'=' -f2
}

sign_data_with_cert() {
  openssl dgst -sha256 -sign "${1}" "${2}"
}

get_data_binary() {
  openssl dgst -sha256 -binary "${1}"
}