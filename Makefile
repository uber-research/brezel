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
install: brezel/cli/brzl_init
	@echo "Enter the following command to install the Brezel CLI in the current shell:"
	@echo ""
	@echo "  source '${PWD}/$<'"
	@echo ""
	@echo "Copy it in your ~/.bashrc or ~/.zshrc to make brzl permanently available."
