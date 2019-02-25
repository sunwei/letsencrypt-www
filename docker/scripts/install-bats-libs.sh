#!/usr/bin/env bash

BASE_DIR=$(dirname $0)
SCRIPT_PATH="$( cd "${BASE_DIR}" && pwd -P )"
TEST_LIB_DIR="${SCRIPT_PATH}/../test/libs"

if [[ ! -d "${TEST_LIB_DIR}" ]]; then
  echo "Create test lib directory..."
  mkdir -p "${TEST_LIB_DIR}"
fi

cd -P "${TEST_LIB_DIR}" && pwd

git submodule add -f https://github.com/sstephenson/bats bats
git submodule add -f https://github.com/ztombol/bats-support bats-support
git submodule add -f https://github.com/ztombol/bats-assert bats-assert