#!libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

source 'lib/jwt.sh'

setup() {
  echo "setup for jwt test..."
}

teardown() {
  echo "tear down from jwt test..."
}

@test "Should get jwt json" {
  run get_jwt_json "account-url" "url" "nonce"
  assert_output '{"alg": "RS256", "kid": "account-url", "url": "url", "nonce": "nonce"}'
}

@test "Should get jws json" {
  run get_jws_json "exp" "mod" "url" "nonce"
  assert_output '{"alg": "RS256", "jwk": {"e": "exp", "kty": "RSA", "n": "mod"}, "url": "url", "nonce": "nonce"}'
}

