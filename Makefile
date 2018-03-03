fqdn ?= yimi.pro

# SSL certs automation with LetsEncrypt

issue:
	docker-compose -f docker-compose.yml run --rm \
	-e FQDN=$(fqdn) letsencrypt-https