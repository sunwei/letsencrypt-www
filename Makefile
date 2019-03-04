fqdn ?= jsoneditoronline.cn

unlock:
	./unlock.sh

export-dnspod-env: unlock
	source ./secrets/dnspod.env

clean-cert:
	rm -rf ./cert/*

update-submodule:
	git submodule update --init --recursive

tests: update-submodule
	./test/libs/bats/bin/bats ./test/*.sh

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