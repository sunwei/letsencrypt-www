#!/bin/bash
set -e

CA="https://acme-v02.api.letsencrypt.org/directory"
FQDN=""
CHALLENGE_TYPE="dns-01"
CERTDIR="./cert"

_generate_private_key() {
    echo " + Generating private key..."
    openssl genrsa -out "${1}" 2048
}

_issue_domain() {
    local timestamp="$(date +%s)"
    local domain="${FQDN}"
    privatekey="${CERTDIR}/private-${timestamp}.pem"

    _generate_private_key "${privatekey}"

    cat "${privatekey}"
}

main() {
    FQDN="${1}"
    _issue_domain
}

main "${@-}"
