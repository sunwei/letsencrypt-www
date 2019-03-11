#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/base64.sh'

setup() {
  echo "setup for domain tests..."
}

teardown() {
  echo "tear down from formatter tests..."
}

@test 'Should get url base64' {
  run urlbase64 <<< "https://sunwei.xyz"
  assert_output "aHR0cHM6Ly9zdW53ZWkueHl6Cg"
}
