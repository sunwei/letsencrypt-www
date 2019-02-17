fqdn ?= abc.fsky.top

# SSL certs automation with LetsEncrypt

issue:
	docker-compose -f docker-compose.yml run --rm \
	-e FQDN=$(fqdn) letsencrypt-https

tests:
	./test/libs/bats/bin/bats ./test/*.bats

# Run this file (with 'entr' installed) to watch all files and rerun tests on changes
watch:
	ls -d **/* | entr ./test.sh
