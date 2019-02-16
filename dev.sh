#!/usr/bin/env bash

# Run this file (with 'entr' installed) to watch all files and rerun tests on changes

ls -d **/* | entr ./test.sh
