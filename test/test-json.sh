#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/json.sh'

setup() {
  DUMMY_DATA='{"id":8309983,"key":{"kty":"RSA"},"contact":["mailto:me@sunwei.xyz"],"status":"valid"}'
  DUMMY_ID=8309983
  DUMMY_STRING="valid"
  DUMMY_ARRAY='"mailto:me@sunwei.xyz"'
  DUMMY_DICT='"kty":"RSA"'
}

teardown() {
  echo "tear down from json test..."
}

@test "Should get json int value" {
  intValue=$(echo "${DUMMY_DATA}" | get_json_int_value id)
  assert_equal $(echo "${intValue}") "${DUMMY_ID}"
}

@test "Should get json string value" {
  strValue=$(echo "${DUMMY_DATA}" | get_json_string_value status)
  assert_equal $(echo "${strValue}") "${DUMMY_STRING}"
}

@test "Should get json array value" {
  arrValue=$(echo "${DUMMY_DATA}" | get_json_array_value contact)
  assert_equal $(echo "${arrValue}") "${DUMMY_ARRAY}"
}

@test "Should get json dict value" {
  dictValue=$(echo "${DUMMY_DATA}" | get_json_dict_value key)
  assert_equal $(echo "${dictValue}") "${DUMMY_DICT}"
}

@test "Should get string value from json data" {
  run get_json_url_by_name "${DUMMY_DATA}" "status"
  assert_output "valid"
}
