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

watch:
	ls -d **/* | entr make tests

test-domain:
	./test/libs/bats/bin/bats ./test/test-domain.sh

watch-domain:
	ls -d test/test-domain.sh | entr make test-domain

clean-cert:
	rm -rf ./cert/*