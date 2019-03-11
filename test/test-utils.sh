#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/utils.sh'

setup() {
  echo "Setup for utils tests"
}

teardown() {
  echo "tear down for utils tests..."
}

@test 'Should create a new tmp file' {
  tmp_file="$(mk_tmp_file)"
  assert [ -e "${tmp_file}" ]
  rm "${tmp_file}"
}

@test 'Should exit error 1 with specified message' {
  run exit_err "error message"
  assert_output "ERROR: error message"
  assert_failure
}

@test 'Should print message start with right mark' {
  run check_msg "the message"
  assert_output "✔ the message"
  assert_success
}

@test 'Should get timestamp' {
  run get_timestamp
  assert_success
}



