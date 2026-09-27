CC ?= cc
CFLAGS ?= -O2 -g -Wall -Wextra -Wpedantic -Wformat=2 -fstack-protector-strong
BUILD_DIR := build
PREFIX ?= /usr/local/lib/lab1

.PHONY: all install uninstall clean

all: $(BUILD_DIR)/lab1_vuln $(BUILD_DIR)/lab1_fixed \
	$(BUILD_DIR)/lab1_cap_probe $(BUILD_DIR)/path/lab1-helper \
	$(BUILD_DIR)/liblab1_preload.so

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/lab1_vuln: src/vulnerable/lab1_vuln.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/lab1_fixed: src/fixed/lab1_fixed.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/lab1_cap_probe: src/fixed/cap_net_raw_probe.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/path/lab1-helper: src/attacks/path_hijack_helper.c
	mkdir -p $(BUILD_DIR)/path
	$(CC) $(CFLAGS) -o $@ $<

$(BUILD_DIR)/liblab1_preload.so: src/attacks/preload_marker.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -fPIC -shared -o $@ $<

install: all
	sudo install -d -o root -g root -m 0755 $(PREFIX)
	sudo install -o root -g root -m 0755 $(BUILD_DIR)/lab1_vuln $(PREFIX)/lab1_vuln
	sudo install -o root -g root -m 0755 $(BUILD_DIR)/lab1_fixed $(PREFIX)/lab1_fixed
	sudo install -o root -g root -m 0755 $(BUILD_DIR)/lab1_cap_probe $(PREFIX)/lab1_cap_probe
	sudo chmod 4755 $(PREFIX)/lab1_vuln $(PREFIX)/lab1_fixed

uninstall:
	sudo setcap -r $(PREFIX)/lab1_cap_probe 2>/dev/null || true
	sudo rm -f $(PREFIX)/lab1_vuln $(PREFIX)/lab1_fixed $(PREFIX)/lab1_cap_probe
	sudo rmdir $(PREFIX) 2>/dev/null || true

clean:
	rm -rf $(BUILD_DIR)