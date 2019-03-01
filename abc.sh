#!/bin/bash
set -e

count="$(echo "string.with.dots." | grep -o "\." | wc -l)"

if [[ "${count}" -gt 1 ]]; then
  echo "large"
  echo "$(echo "a.b.c" | cut -d'.' -f1)"
fi

echo $count