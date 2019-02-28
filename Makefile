fqdn ?= abc.fsky.top

# SSL certs automation with LetsEncrypt

build:
	docker-compose build letsencrypt

unlock:
	./unlock.sh

push: unlock
	./docker-push.sh

issue:
	docker-compose -f docker-compose.yml run --rm \
	-e FQDN=$(fqdn) letsencrypt

shell:
	docker-compose -f docker-compose.yml run --rm \
	 -e FQDN=$(fqdn) letsencrypt \
	/bin/bash

install-tests-lib:
	[[ ! -d "./test/libs" ]] \
		&& echo "Create test lib directory..." \
		&& mkdir -p "./test/libs" \
		&& cd -P "./test/libs" && pwd \
		&& git submodule add -f https://github.com/sstephenson/bats bats \
		&& git submodule add -f https://github.com/ztombol/bats-support bats-support \
		&& git submodule add -f https://github.com/ztombol/bats-assert bats-assert \

tests:
	./test/libs/bats/bin/bats ./test/*.sh

install-entr:
	mkdir tmp && cd tmp \
	&& git clone https://github.com/clibs/entr.git \
	&& cd entr \
	&& ./configure && make test && make install \
	&& rm -rf tmp \

# Run this file (with 'entr' installed) to watch all files and rerun tests on changes
watch:
	ls -d **/* | entr make tests

test-http:
	./test/libs/bats/bin/bats ./test/test-http.sh

watch-http:
	ls -d test/test-http.sh | entr make test-http

test-lev2:
	./test/libs/bats/bin/bats ./test/test-letsencrypt-v2.sh

watch-lev2:
	ls -d test/test-letsencrypt-v2.sh | entr make test-lev2