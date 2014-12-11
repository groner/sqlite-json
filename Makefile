sqlite-json-so = sqlite-json.dylib

all: $(sqlite-json-so)

CFLAGS += -g
CFLAGS += -Wall -Werror
CFLAGS += -fvisibility=hidden

# Manual export because make is stupid or something
pkg-config = PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config

json-c-cflags  = $(shell $(pkg-config) --cflags json-c)
json-c-libs    = $(shell $(pkg-config) --libs json-c)

sqlite3-cflags = $(shell $(pkg-config) --cflags sqlite3)
sqlite3-libs   = $(shell $(pkg-config) --libs sqlite3)

sqlite-json-objects += sqlite-init.o
sqlite-json-objects += json-functions.o

$(sqlite-json-objects): CFLAGS += $(json-c-cflags)
$(sqlite-json-objects): CFLAGS += $(sqlite3-cflags)

clean::
	$(RM) $(sqlite-json-objects)


$(sqlite-json-so): $(sqlite-json-objects)
$(sqlite-json-so): LDFLAGS += -lc
$(sqlite-json-so): LDFLAGS += $(json-c-libs)
$(sqlite-json-so): LDFLAGS += $(sqlite3-libs)
$(sqlite-json-so): | json-c/libjson-c.la

clean::
	$(RM) $(sqlite-json-so)


### json-c
json-c:
	$(info Updating json-c)
	@set -x; \
	if ! test -d json-c; then \
	    git clone http://github.com/json-c/json-c; \
	else \
	    cd json-c && git pull; \
	fi

json-c/configure.ac json-c/Makefile.am: | json-c

json-c/Makefile: json-c/configure.ac json-c/Makefile.am
	$(info Configuring json-c)
	@set -x; \
	cd json-c && ./autogen.sh && ./configure

json-c/libjson-c.la: json-c/Makefile
	$(info Building json-c)
	make -C json-c


test: tests


### sql-tests
# Any tests/*.sql file will be executed with $(sqlite3-test) and it's output
# compared to expected output.
# The sql-tests-refresh target can be used to review discrepancies and
# selectively apply the changes by editing the diff.

tests: sql-tests
sql-tests = $(patsubst tests/%.sql,%,$(wildcard tests/*.sql))
sqlite3-test = $(sqlite3) -column -header -echo -nullvalue NULL -cmd '.load sqlite-json' <

sql-tests: $(sql-tests:%=sql-test-%)

$(sql-tests:%=tests/%.out):
	touch $@

.SECONDEXPANSION:

$(sql-tests:%=sql-test-%): testbase = $(@:sql-test-%=tests/%)
$(sql-tests:%=sql-test-%): sql = $(testbase).sql
$(sql-tests:%=sql-test-%): out = $(testbase).out
$(sql-tests:%=sql-test-%): $$(sql) $$(out) $$(sqlite-json-so)
$(sql-tests:%=sql-test-%):
	$(sqlite3-test) $(sql) 2>&1 | diff -U5 $(out) -

sql-tests-refresh: $(sql-tests:%=sql-test-%-refresh)

$(sql-tests:%=sql-test-%-refresh): testbase = $(@:sql-test-%-refresh=tests/%)
$(sql-tests:%=sql-test-%-refresh): sql = $(testbase).sql
$(sql-tests:%=sql-test-%-refresh): out = $(testbase).out
$(sql-tests:%=sql-test-%-refresh): patch = $(testbase).patch
$(sql-tests:%=sql-test-%-refresh): check-editdiff
$(sql-tests:%=sql-test-%-refresh): $$(sql) $$(out) $$(sqlite-json-so)
$(sql-tests:%=sql-test-%-refresh):
	@set -x; \
	if ! $(sqlite3-test) $(sql) 2>&1 | diff -U5 $(out) - >$(patch); then \
	    editdiff $(patch); \
	    patch -Nt $(out) < $(patch); \
	fi
	$(RM) $(patch) $(patch).orig

check-editdiff:
	@if ! which editdiff >/dev/null; then \
	    echo 'editdiff not found.  Please install patchutils.'; \
	    exit 1; \
	fi


# TODO: portability

# Apple's libtool
%.dylib:
	libtool -dynamic $(LDFLAGS) -o $@ $+

-include local.mk

sqlite3 ?= sqlite
