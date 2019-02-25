#!/bin/bash
set -e

generate_rsa_to() {
    openssl genrsa -out "${1}" 2048
}
