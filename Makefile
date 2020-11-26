ROOT := .

.PHONY: prepare
prepare:
	@$(ROOT)/scripts/prepare.sh

.PHONY: build
build:
	@$(ROOT)/scripts/build.sh

build-%:
	@$(ROOT)/scripts/build.sh -$(subst -, -,$*)

.PHONY: run
run:
	@$(ROOT)/scripts/run.sh

run-%:
	@$(ROOT)/scripts/run.sh -$(subst -, -,$*)

.PHONY: test
test:
	@$(ROOT)/scripts/test.sh

.PHONY: install
PWD := $(shell pwd)
install: brezel/cli/brzl_init
	@echo "Execute the following command to install the Brezel CLI in the current shell:"
	@echo ""
	@echo "\033[1m  source '$(PWD)/$<'  \033[0m"
	@echo ""
	@echo "====================================================================================="
	@echo "==    Copy it in your ~/.bashrc or ~/.zshrc to make brzl permanently available.    =="
	@echo "====================================================================================="
