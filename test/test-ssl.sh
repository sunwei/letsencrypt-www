#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/ssl.sh'

setup() {
  echo "Setup for ssl tests"
  _TMP_FILE="/tmp/letsencrypt-www-for-generate-rsa-2048-test"
  _TMP_KEY="/tmp/letsencrypt-www-account-key"
}

teardown() {
  echo "tear down for ssl tests..."
  if [[ -f "${_TMP_FILE}" ]] 2>/dev/null; then
        rm "${_TMP_FILE}"
  fi
  if [[ -f "${_TMP_KEY}" ]] 2>/dev/null; then
        rm "${_TMP_KEY}"
  fi
}

@test 'Should exit 0 with ssl lib dependence check' {
  run ssl_check_lib_dependence
  assert_success
}

@test 'Should get location of OpenSSl' {
  run ssl_get_location
#  assert_output --regexp '^.*/OpenSSL$'
  assert_success
}

@test "Should get encrypted base64 data" {
  result=$(echo "abcd" | ssl_base64_encrypt )
  assert_equal "${result}" "YWJjZAo="
}

@test 'Should create a new 2048 rsa file' {
  run ssl_generate_rsa_2048 "${_TMP_FILE}"
  assert [ -s "${_TMP_FILE}" ]
}

@test 'Should print rsa file in text form' {
  run $(echo "_DUMMY_STRING_" | ssl_print_in_text_form )
  assert_success
}

@test 'Should generate subject with domain' {
  run ssl_generate_subject_with_domain "letsencryptwww.com"
  assert_output "/CN=letsencryptwww.com/"
}

@test 'Should generate SAN with domain' {
  run ssl_generate_san_with_domain "letsencryptwww.com"
  assert_output "[SAN]
subjectAltName=DNS:letsencryptwww.com"
}

@test 'Should get public exponent from rsa file' {
  ssl_generate_rsa_2048 "${_TMP_FILE}"
  run ssl_get_rsa_publicExponent "${_TMP_FILE}"
  assert_output 65537
}

@test 'Should get public module from rsa file' {
  ssl_generate_rsa_2048 "${_TMP_FILE}"
  run ssl_get_rsa_pubMod64 "${_TMP_FILE}"
  assert_success
}

@test 'Should sign data with private key' {
  ssl_generate_rsa_2048 "${_TMP_KEY}"
  result=$(echo "test data" | ssl_sign_data_with_cert "${_TMP_KEY}" | ssl_base64_encrypt)
  assert [ ! -z "${result}" ]
}

@test 'Should get data binary' {
  result=$( echo "data abc" | ssl_get_data_binary | ssl_base64_encrypt )
  assert_equal "${result}" "ufZNNBFqRhg2bWYpVZBvbyTAelREwnuITMuGsajFoUs="
}

#@test 'Should generate rsa with private key' {
#  ssl_generate_rsa_2048 "${_TMP_KEY}"
#  run generate_csr "${_TMP_KEY}" "${_TMP_FILE}"
#  assert [ -s "${_TMP_FILE}" ]
#}