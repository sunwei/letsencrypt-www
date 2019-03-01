#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/domain.sh'

setup() {
  echo "setup for domain tests..."
}

teardown() {
  echo "tear down from formatter tests..."
}

@test 'Should exit 0 with domain lib dependence check' {
  run domain_check_lib_dependence
  assert_success
}

@test "Should find sub domain" {
  run has_sub_domain "a.b.c"
  assert_output True
}

@test "Should not find sub domain" {
  run has_sub_domain "b.c"
  assert_output False
}

@test "Should get sub domain when there is sub domain" {
  run get_sub_domain <<<"a.b.c"
  assert_output "a"
}

@test "Should get sub domain when there is sub domain" {
  run get_sub_domain <<<"a.a.b.c"
  assert_output "a.a"
}

@test "Should get domain when there is sub domain" {
  run get_domain <<<"a.b.c"
  assert_output "b.c"
}

@test "Should get domain when there isn't sub domain" {
  run get_domain <<<"b.c"
  assert_output "b.c"
}
