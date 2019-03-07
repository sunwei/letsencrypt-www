#!/bin/bash
set -e

if [[ "${ENV}" = "prod" ]]; then
 www -p "${FQDN}"
else
 www "${FQDN}"
fi