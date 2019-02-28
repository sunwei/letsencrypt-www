#!/bin/bash
set -e

arr="a","b"
arr1=("a", "b")
array=("A" "B" "ElementC" "ElementE")

echo ${array}

for uri in ${arr[@]}; do
  echo "${uri}"
done

for uri in "${array[@]}"; do
  echo "${uri}"
done

