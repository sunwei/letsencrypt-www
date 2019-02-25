#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'


@test 'assert_failure() status only' {
  run echo 'Success!'
  assert_success
}

@test 'assert_output()' {
  run echo 'have'
  assert_output 'have'
}

@test 'assert_output() partial matching' {
  run echo 'ERROR: no such file or directory'
  assert_output --partial 'ERROR'
}

@test 'assert_output() regular expression matching' {
  run echo 'Foobar v0.1.0'
  assert_output --regexp '^Foobar v[0-9]+\.[0-9]+\.[0-9]$'
}

@test 'assert_line() looking for line' {
  run echo $'have-0\nhave-1\nhave-2'
  assert_line 'have-1'
}
