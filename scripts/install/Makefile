.PHONY: test

%_test : %.sh
	docker run --rm -v $(shell pwd):/tests ubuntu:18.04 /tests/$< >/dev/null

test: $(patsubst %.sh,%_test,$(wildcard *.sh))
