fqdn ?= example.sunzhongmou.com

unlock:
	./unlock.sh

update-submodule:
	git submodule update --init --recursive

tests: update-submodule
	export LETS_ENCRYPT_WWW_LIB_PATH=$(CURDIR)/lib && \
	./test/libs/bats/bin/bats ./test/*.sh

build:
	docker-compose build letsencrypt-www

push: unlock
	./docker-push.sh

issue:
	docker-compose -f docker-compose.yml -f docker-compose.override.yml run --rm \
	-e FQDN=$(fqdn) letsencrypt-www

shell:
	docker-compose -f docker-compose.yml -f docker-compose.override.yml run --rm \
	 -e FQDN=$(fqdn) letsencrypt-www \
	/bin/bash

setup-dev:
	mkdir tmp && cd tmp \
	&& git clone https://github.com/clibs/entr.git \
	&& cd entr \
	&& ./configure && make test && make install \
	&& rm -rf tmp \

watch:
	ls -d **/* | entr make tests

install-tests-lib:
	[[ ! -d "./test/libs" ]] \
		&& echo "Create test lib directory..." \
		&& mkdir -p "./test/libs" \
		&& cd -P "./test/libs" && pwd \
		&& git submodule add -f https://github.com/sstephenson/bats bats \
		&& git submodule add -f https://github.com/ztombol/bats-support bats-support \
		&& git submodule add -f https://github.com/ztombol/bats-assert bats-assert