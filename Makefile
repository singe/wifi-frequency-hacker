WIRELESS_REGDB_DIR ?= $(HOME)/wireless-regdb
PYTHON ?= python3
DB_TXT := db.txt
REGDB := regulatory.db
REGDB_SIG := regulatory.db.p7s

.PHONY: all build install clean help

all: build

help:
	@printf '%s\n' \
		'Targets:' \
		'  make build    Build regulatory.db from db.txt using an upstream wireless-regdb tree' \
		'  make install  Build and install regulatory.db into /lib/firmware' \
		'  make clean    Remove generated regulatory.db artifacts'

build: $(REGDB)

$(REGDB): $(DB_TXT)
	@test -d "$(WIRELESS_REGDB_DIR)" || { \
		printf '%s\n' "wireless-regdb tree not found: $(WIRELESS_REGDB_DIR)"; \
		printf '%s\n' "Set WIRELESS_REGDB_DIR to a checked-out wireless-regdb source tree."; \
		exit 1; \
	}
	cp "$(DB_TXT)" "$(WIRELESS_REGDB_DIR)/db.txt"
	$(PYTHON) "$(WIRELESS_REGDB_DIR)/db2fw.py" "$(REGDB)" "$(WIRELESS_REGDB_DIR)/db.txt"
	rm -f "$(REGDB_SIG)"

install: $(REGDB)
	install -m 0644 $(REGDB) /lib/firmware/$(REGDB)

clean:
	rm -f $(REGDB) $(REGDB_SIG)
