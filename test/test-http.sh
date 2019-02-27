#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/http.sh'

setup() {
  echo "Setup for http tests"
}

teardown() {
  echo "tear down for ssl tests..."
}

@test 'Should exit 0 with http lib dependence check' {
  run http_check_lib_dependence
  assert_success
}

@test 'Should create a new http tmp file' {
  tmp_file="$(_http_mk_tmp_file)"
  assert [ -e "${tmp_file}" ]
  rm "${tmp_file}"
}

@test 'Should get curl version' {
  run _get_curl_version
  assert_success
}

@test 'Should get letsencryptwww version' {
  run _get_letsencrypt_www_version
  assert_output "letsencrypt-www/0.0.1"
}

@test 'Should get curl agent' {
  run _get_client_agent
  assert_output --partial "letsencrypt-www/0.0.1 curl/"
}

@test 'Should get jose json content type' {
  run http_get_content_type jose
  assert_output "Content-Type: application/jose+json"
}

@test 'Should get default content type' {
  run http_get_content_type
  assert_output "Content-Type: application/x-www-form-urlencoded"
}

@test 'Should handle curl error and message' {
  run _handle_response 1 4 https://api.letsencryptwww.com HEAD
  assert_output "Connection problem: https://api.letsencryptwww.com with method HEAD, curl code is 1 "
  assert_failure
}

@test 'Should handle response error and message' {
  run _handle_response 0 4 https://api.letsencryptwww.com HEAD
  assert_output "Http problem: https://api.letsencryptwww.com with method HEAD, http code is 4 "
  assert_failure
}

@test 'Should handle no error with correct input' {
  run _handle_response 0 2 https://api.letsencryptwww.com HEAD
  assert_success
}
