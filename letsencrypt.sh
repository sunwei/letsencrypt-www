#!/bin/bash

set -e
set -u
set -o pipefail

exec 3>&-

source letscommon.sh


CA="https://acme-staging-v02.api.letsencrypt.org/directory"
CA_ACCOUNT=
CA_NEW_ORDER="https://acme-staging-v02.api.letsencrypt.org/acme/new-order"
CA_NEW_NONCE="https://acme-staging-v02.api.letsencrypt.org/acme/new-nonce"
CA_NEW_ACCOUNT="https://acme-staging-v02.api.letsencrypt.org/acme/new-acct"

ACCOUNT_KEY_JSON="./cert/account-key.json"
ACCOUNT_ID=
ACCOUNT_URL=
FQDN="abcd.sunzhongmou.com"
SUBJ=""
CHALLENGE_TYPE="dns-01"
CERTDIR="./cert"

pubExponent64=
pubMod64=
thumbPrint=

challenge_names=()
challenge_tokens=()
challenge_uris=()
keyauth=
keyauth_hook=
keyauths=()
deploy_args=()
num_pending_challenges=

_generate_private_key() {
    echo " + Generating private key..."
    openssl genrsa -out "${1}" 2048
}

_generate_csr() {
    prikey="${1}"
    shift
    csr="${1}"

    SUBJ="/CN=${FQDN}/"
    SAN="DNS:abcd.sunzhongmou.com"
    tmp_openssl_cnf="$(_mktemp)"
    printf "[SAN]\nsubjectAltName=%s" "${SAN}" >> "${tmp_openssl_cnf}"

    openssl req -new -sha256 -key "${prikey}" -out "${csr}" -subj "${SUBJ}" -reqexts SAN -config "${tmp_openssl_cnf}"
}

_generate_account_key() {
    echo " + Generating account key..."
    openssl genrsa -out "${1}" 2048
}

_register_account() {
    echo "+ Registering account key with ACME server..."
    local accountKey="${1}"

    pubExponent64="$(printf '%x' "$(openssl rsa -in "${accountKey}" -noout -text | awk '/publicExponent/ {print $2}')" | hex2bin | urlbase64)"
    pubMod64="$(openssl rsa -in "${accountKey}" -noout -modulus | cut -d'=' -f2 | hex2bin | urlbase64)"

    thumbPrint="$(printf '{"e":"%s","kty":"RSA","n":"%s"}' "${pubExponent64}" "${pubMod64}" | openssl dgst -sha256 -binary | urlbase64)"

    nonce="$(http_request HEAD "${CA_NEW_NONCE}" | grep -i ^Replay-Nonce: | awk -F ': ' '{print $2}' | tr -d '\n\r')"
    header='{"alg": "RS256", "jwk": {"e": "'"${pubExponent64}"'", "kty": "RSA", "n": "'"${pubMod64}"'"}}'

    protected='{"alg": "RS256", "jwk": {"e": "'"${pubExponent64}"'", "kty": "RSA", "n": "'"${pubMod64}"'"}, "url": "'"${CA_NEW_ACCOUNT}"'", "nonce": "'"${nonce}"'"}'
    protected64="$(printf '%s' "${protected}" | urlbase64)"

    payload='{"contact":["mailto:'me@sunwei.xyz'"], "termsOfServiceAgreed": true}'
    payload64=$(printf '%s' "${payload}" | urlbase64)

    signed64="$(printf '%s' "${protected64}.${payload64}" | openssl dgst -sha256 -sign "${accountKey}" | urlbase64)"
    data='{"protected": "'"${protected64}"'", "payload": "'"${payload64}"'", "signature": "'"${signed64}"'"}'

    http_request POST "${CA_NEW_ACCOUNT}" "${data}" > "${ACCOUNT_KEY_JSON}"

    if [[ -e "${ACCOUNT_KEY_JSON}" ]]; then
        ACCOUNT_ID="$(cat "${ACCOUNT_KEY_JSON}" | get_json_int_value id)"
        CA_ACCOUNT=${CA_NEW_ACCOUNT/new-acct/acct}
        ACCOUNT_URL="${CA_ACCOUNT}/${ACCOUNT_ID}"
    fi
}

_new_order(){
    accountKey="${1}"
    echo "> Requesting new cert order from Let's Encrypt CA..."

    payload='{"identifiers": [{"type": "dns", "value": "abcd.sunzhongmou.com"}]}'
    payload64=$(printf '%s' "${payload}" | urlbase64)

    nonce="$(http_request HEAD "${CA_NEW_NONCE}" | grep -i ^Replay-Nonce: | awk -F ': ' '{print $2}' | tr -d '\n\r')"

    header='{"alg": "RS256", "jwk": {"e": "'"${pubExponent64}"'", "kty": "RSA", "n": "'"${pubMod64}"'"}}'
    protected='{"alg": "RS256", "kid": "'"${ACCOUNT_URL}"'", "url": "'"${CA_NEW_ORDER}"'", "nonce": "'"${nonce}"'"}'
    protected64="$(printf '%s' "${protected}" | urlbase64)"

    signed64="$(printf '%s' "${protected64}.${payload64}" | openssl dgst -sha256 -sign "${accountKey}" | urlbase64)"
    data='{"protected": "'"${protected64}"'", "payload": "'"${payload64}"'", "signature": "'"${signed64}"'"}'

    http_request POST "${CA_NEW_ORDER}" "${data}"
}

_build_deploy_args() {
    local certOrder="${1}"

    order_authorizations="$(echo ${certOrder} | get_json_array_value authorizations)"
    finalize="$(echo "${certOrder}" | get_json_string_value finalize)"

    local idx=0
    for uri in ${order_authorizations}; do
        authorizations[${idx}]="$(echo "${uri}" | sed -E -e 's/\"(.*)".*/\1/')"
        idx=$((idx+1))
    done
    echo " + Received ${idx} authorizations URLs from the CA"

    local idx=0
    for authorization in ${auththorizations[*]}; do
        response="$(http_request GET "$(echo "${authorization}" | sed -E -e 's/\"(.*)".*/\1/' | clean_json)")"
        identifier="$(echo "${response}" | get_json_dict_value identifier | get_json_string_value value)"
        echo " + Handling authorization for ${identifier}"


        if [[ "valid" = "$(echo "${response}" | sed -E 's/"challenges": \[\{.*\}\]//' | get_json_string_value status)" ]]; then
            echo " + Found valid authorization for ${identifier}"
            continue
        fi

        # Find challenge in authorization
        challenges="$(echo "${response}" | _sed 's/.*"challenges": \[(\{.*\})\].*/\1/')"
        challenge="$(<<<"${challenges}" _sed -e 's/^[^\[]+\[(.+)\]$/\1/' -e 's/\}(, (\{)|(\]))/}\'$'\n''\2/g' | grep \""${CHALLENGE_TYPE}"\" || true)"
        if [ -z "${challenge}" ]; then
          allowed_validations="$(grep -Eo '"type": "[^"]+"' <<< "${challenges}" | grep -Eo ' "[^"]+"' | _sed -e 's/"//g' -e 's/^ //g')"
          _exiterr "Validating this certificate is not possible using ${CHALLENGE_TYPE}. Possible validation methods are: ${allowed_validations}"
        fi

        # Gather challenge information
        challenge_names[${idx}]="${identifier}"
        challenge_tokens[${idx}]="$(echo "${challenge}" | get_json_string_value token)"
        challenge_uris[${idx}]="$(echo "${challenge}" | _sed 's/"validationRecord": ?\[[^]]+\]//g' | get_json_string_value url)"

        # Prepare challenge tokens and deployment parameters
        keyauth="${challenge_tokens[${idx}]}.${thumbPrint}"
        keyauth_hook="$(printf '%s' "${keyauth}" | openssl dgst -sha256 -binary | urlbase64)"
        keyauths[${idx}]="${keyauth}"
        deploy_args[${idx}]="${identifier} ${challenge_tokens[${idx}]} ${keyauth_hook}"

        idx=$((idx+1))
    done

    num_pending_challenges=${idx}
    echo " + ${num_pending_challenges} pending challenge(s)"
}

_create_txt_record() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo "deploy_challenge called: ${DOMAIN}, ${TOKEN_FILENAME}, ${TOKEN_VALUE}"

    lexicon dnspod create ${DOMAIN} TXT --name="_acme-challenge.${DOMAIN}." --content="${TOKEN_VALUE}"

    sleep 30
}

_deploy_challenge() {
    local idx=0
    while [ ${idx} -lt ${num_pending_challenges} ]; do
        $(_create_txt_record ${deploy_args[${idx}]})
        idx=$((idx+1))
    done
}

_validate_pending_challenge() {
    local idx=0
    while [ ${idx} -lt ${num_pending_challenges} ]; do
        echo " + Responding to challenge for ${challenge_names[${idx}]} authorization..."

        # Ask the acme-server to verify our challenge and wait until it is no longer pending
        if [[ ${API} -eq 1 ]]; then
            result="$(signed_request "${challenge_uris[${idx}]}" '{"resource": "challenge", "keyAuthorization": "'"${keyauths[${idx}]}"'"}' | clean_json)"
        else
            result="$(signed_request "${challenge_uris[${idx}]}" '{"keyAuthorization": "'"${keyauths[${idx}]}"'"}' | clean_json)"
        fi

        reqstatus="$(printf '%s\n' "${result}" | get_json_string_value status)"

        while [[ "${reqstatus}" = "pending" ]]; do
            sleep 1
            result="$(http_request get "${challenge_uris[${idx}]}")"
            reqstatus="$(printf '%s\n' "${result}" | get_json_string_value status)"
        done

        if [[ "${reqstatus}" = "valid" ]]; then
            echo " + Challenge is valid!"
        else
            [[ -n "${HOOK}" ]] && "${HOOK}" "invalid_challenge" "${altname}" "${result}"
        break
    fi
    idx=$((idx+1))
    done

    if [[ ${num_pending_challenges} -ne 0 ]]; then
        echo " + Cleaning challenge tokens..."

        # Clean challenge tokens using chained hook
        [[ -n "${HOOK}" ]] && [[ "${HOOK_CHAIN}" = "yes" ]] && "${HOOK}" "clean_challenge" ${deploy_args[@]}

        # Clean remaining challenge tokens if validation has failed
        local idx=0
        while [ ${idx} -lt ${num_pending_challenges} ]; do
          # Delete challenge file
          [[ "${CHALLENGETYPE}" = "http-01" ]] && rm -f "${WELLKNOWN}/${challenge_tokens[${idx}]}"
          # Delete alpn verification certificates
          [[ "${CHALLENGETYPE}" = "tls-alpn-01" ]] && rm -f "${ALPNCERTDIR}/${challenge_names[${idx}]}.crt.pem" "${ALPNCERTDIR}/${challenge_names[${idx}]}.key.pem"
          # Clean challenge token using non-chained hook
          [[ -n "${HOOK}" ]] && [[ "${HOOK_CHAIN}" != "yes" ]] && "${HOOK}" "clean_challenge" ${deploy_args[${idx}]}
          idx=$((idx+1))
        done

        if [[ "${reqstatus}" != "valid" ]]; then
          echo " + Challenge validation has failed :("
          _exiterr "Challenge is invalid! (returned: ${reqstatus}) (result: ${result})"
        fi
    fi
}

_issue_domain() {
    local timestamp="$(date +%s)"

    accountkey="${CERTDIR}/account-key-${timestamp}.pem"
    privatekey="${CERTDIR}/private-${timestamp}.pem"
    csr="${CERTDIR}/${timestamp}.csr"

    _generate_account_key "${accountkey}"
    _register_account "${accountkey}"
    result="$(_new_order "${accountkey}")"

    _generate_private_key "${privatekey}"
    _generate_csr "${privatekey}" "${csr}"

    _build_deploy_args result
    _deploy_challenge
    _validate_pending_challenge




    echo "${result}"

}

main() {
    FQDN="${1}"
    _issue_domain
}

main "${@-}"
