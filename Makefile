PKGS := $(shell go list ./... | grep -v /vendor)

SYSTEMD_FILENAME := skbl.service
SYSTEMD_SOURCE_DIR := systemd/
SYSTEMD_SOURCE_PATH := $(SYSTEMD_SOURCE_DIR)$(SYSTEMD_FILENAME)
SYSTEMD_TARGET_DIR := /usr/lib/systemd/user/
SYSTEMD_TARGET_PATH := $(SYSTEMD_TARGET_DIR)$(SYSTEMD_FILENAME)

BIN_FILENAME := skbl
BIN_SOURCE_DIR := bin/
BIN_SOURCE_PATH := $(BIN_SOURCE_DIR)$(BIN_FILENAME)
BIN_TARGET_DIR := /usr/bin/
BIN_TARGET_PATH := $(BIN_TARGET_DIR)$(BIN_FILENAME)

CONFIG_FILENAME := config.toml
CONFIG_SOURCE_DIR := ./
CONFIG_SOURCE_PATH := $(CONFIG_SOURCE_DIR)$(CONFIG_FILENAME)
CONFIG_TARGET_DIR := /etc/skbl/
CONFIG_TARGET_PATH := $(CONFIG_TARGET_DIR)$(CONFIG_FILENAME)

.PHONY: test
test:
	go test $(PKGS)

.PHONY: build
build:
	go build -o $(BIN_SOURCE_PATH)

.PHONY: clean
clean:
	rm -rf bin/

.PHONY: install
install: $(BIN_TARGET_PATH) $(SYSTEMD_TARGET_PATH) config_dir $(CONFIG_TARGET_PATH)
	systemctl --user daemon-reload

$(BIN_TARGET_PATH): build
	sudo cp -f $(BIN_SOURCE_PATH) $(BIN_TARGET_DIR)

$(SYSTEMD_TARGET_PATH): $(SYSTEMD_SOURCE_PATH)
	sudo cp -f $(SYSTEMD_SOURCE_PATH) $(SYSTEMD_TARGET_DIR)

.PHONY: config-dir
config_dir:
	sudo mkdir -p $(CONFIG_TARGET_DIR)

$(CONFIG_TARGET_PATH): $(CONFIG_SOURCE_PATH)
	sudo cp -f $(CONFIG_SOURCE_PATH) $(CONFIG_TARGET_DIR)
	sudo chmod 664 $(SYSTEMD_TARGET_PATH)

.PHONY: uninstall
uninstall:
	test -f $(SYSTEMD_TARGET_PATH) && sudo rm $(SYSTEMD_TARGET_PATH)
	test -d $(CONFIG_TARGET_DIR) && sudo rm -r $(CONFIG_TARGET_DIR)
	test -f $(BIN_TARGET_PATH) && sudo rm $(BIN_TARGET_PATH)
	sudo systemctl --user daemon-reload