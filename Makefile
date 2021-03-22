.PHONY: dep-ensure test cover all lint

TOOL_NAME := bcrypt

# Load relative to the common.mk file
include $(dir $(lastword $(MAKEFILE_LIST)))/vars.mk

include ./vars.mk

all:
	@$(MAKE) get-build-deps
	@$(MAKE) download
	@$(MAKE) vet
	@$(MAKE) lint
	@$(MAKE) cover
	@$(MAKE) build

build:
	@go build -ldflags=$(LDFLAGS) -o $(TOOL_PATH)
	@echo "*** Binary created under $(TOOL_PATH) ***"

build/arm64:
	@GOARCH=arm64 go build -ldflags=$(LDFLAGS) -o $(BUILD_DIR)/arm64/$(TOOL_NAME)

clean:
	@rm -rf $(BUILD_DIR)

download:
	$(GO_MOD) download

get-build-deps:
	@echo "+ Downloading build dependencies"
	@go get golang.org/x/tools/cmd/goimports
	@go get golang.org/x/lint/golint


vet:
	@echo "+ Vet"
	@go vet ./...

lint:
	@echo "+ Linting package"
	@golint .
	$(call fmtcheck, .)

test:
	@echo "+ Testing package"
	$(GO_TEST) .

cover: test
	@echo "+ Tests Coverage"
	@mkdir -p $(BUILD_DIR)
	@touch $(BUILD_DIR)/cover.out
	@go test -coverprofile=$(BUILD_DIR)/cover.out
	@go tool cover -html=$(BUILD_DIR)/cover.out -o=$(BUILD_DIR)/coverage.html
