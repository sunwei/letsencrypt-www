#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/formatter.sh'

setup() {
  DUMMY_DATA='{"id":8309983,"key":{"kty":"RSA"},"contact":["mailto:me@sunwei.xyz"],"status":"valid"}'
  DUMMY_DATA_WS='{  "id": 8309983, "key": { "kty":"RSA" }, "contact":  [ "mailto:me@sunwei.xyz" ], "status": "valid"}'
}

teardown() {
  echo "tear down from formatter tests..."
}

@test 'Should exit 0 with formatter lib dependence check' {
  run formatter_check_lib_dependence
  assert_success
}

@test "Should remove json white space" {
  clearValue=$(echo "${DUMMY_DATA_WS}" | clean_json )
  assert_equal $(echo "${clearValue}") "${DUMMY_DATA}"
}

@test "Should encode data as urlbase64 without \n\r, +, /, " {
  urlbase64=$(echo "jpbIm1h+/
eHl6Il0s
" | clen_base64_url )
  assert_equal $(echo "${urlbase64}") "jpbIm1h-_eHl6Il0s"
}

#@test 'Should convert hex to binary string' {
#  binStr="$(printf '%x' 65537 | hex2bin | clen_base64_url )"
#  assert_equal $(echo "${binStr}") "AQAB"
#}