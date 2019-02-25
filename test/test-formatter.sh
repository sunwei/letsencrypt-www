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

@test "Should remove json white space" {
  clearValue=$(echo "${DUMMY_DATA_WS}" | rm_json_ws )
  assert_equal $(echo "${clearValue}") "${DUMMY_DATA}"
}

@test "Should encode data as urlbase64 without \n\r, +, =, /, " {
  urlbase64=$(echo "${DUMMY_DATA}" | urlbase64 )
  assert_equal $(echo "${urlbase64}") "eyJpZCI6ODMwOTk4Mywia2V5Ijp7Imt0eSI6IlJTQSJ9LCJjb250YWN0IjpbIm1haWx0bzptZUBzdW53ZWkueHl6Il0sInN0YXR1cyI6InZhbGlkIn0K"
}

@test 'Should convert hex to binary string' {
  binStr="$(printf '%x' 65537 | hex2bin | url )"
  assert_equal $(echo "${binStr}") "AQAB"
}