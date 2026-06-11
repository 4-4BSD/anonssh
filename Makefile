# Makefile for anon
#
# Prerequisites:
#   ../mruby    # mruby checkout (sibling directory)
#
# Quick start:
#   make        # build bin/anon and libexec/anon/{bootstrap,serve}
#   make clean  # clean build artifacts

MRUBY_DIR    ?= ../mruby
BUILD_CONFIG  = build.rb
BUILD_NAME    = anon
BUILD_DIR     = $(MRUBY_DIR)/build/$(BUILD_NAME)
RUBY_FILES   != find src mrblib -type f -name '*.rb' 2>/dev/null | sort

PREFIX      ?= /usr/local
BINDIR       = $(PREFIX)/bin
LIBEXECDIR    = $(PREFIX)/libexec/anon
SHAREDIR      = $(PREFIX)/share/$(BUILD_NAME)

ANON_ENTRYPOINT        = src/bin/anon.rb
ANON_BIN               = bin/anon
ANON_IREP              = tmp/anon_main.c
ANON_OBJ               = tmp/anon_main.o

BOOTSTRAP_ENTRYPOINT   = src/libexec/anon/bootstrap.rb
BOOTSTRAP_BIN          = libexec/anon/bootstrap
BOOTSTRAP_IREP         = tmp/anon_bootstrap_main.c
BOOTSTRAP_OBJ          = tmp/anon_bootstrap_main.o

SERVE_ENTRYPOINT       = src/libexec/anon/serve.rb
SERVE_BIN              = libexec/anon/serve
SERVE_IREP             = tmp/anon_serve_main.c
SERVE_OBJ              = tmp/anon_serve_main.o

STANDALONE_BINS        = $(ANON_BIN) $(BOOTSTRAP_BIN) $(SERVE_BIN)
STANDALONE_IREPS       = $(ANON_IREP) $(BOOTSTRAP_IREP) $(SERVE_IREP)
STANDALONE_OBJS        = $(ANON_OBJ) $(BOOTSTRAP_OBJ) $(SERVE_OBJ)
STANDALONE_FILES       = main.c

TOOLCHAIN_BIN   = bin/mruby bin/mrbc bin/mruby-config
TOOLCHAIN_STAMP = tmp/toolchain.base-dynamic.stamp

MRBC_FLAGS      = --remove-lv
APP_LDFLAGS    ?=
POST_BUILD     ?= strip

.PHONY: all toolchain standalone clean distclean install deinstall

all: toolchain standalone

toolchain: $(TOOLCHAIN_STAMP)

standalone: $(STANDALONE_BINS)

$(TOOLCHAIN_STAMP): $(BUILD_CONFIG) mrbgem.rake $(RUBY_FILES)
	mkdir -p tmp bin
	ruby -C $(MRUBY_DIR) minirake clean 2>/dev/null || true
	BUILD=base-dynamic ruby -C $(MRUBY_DIR) minirake MRUBY_CONFIG=$$(pwd)/$(BUILD_CONFIG)
	cp -r $(BUILD_DIR)/bin/* bin/
	touch $(TOOLCHAIN_STAMP)

$(ANON_IREP): $(ANON_ENTRYPOINT) $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	bin/mrbc $(MRBC_FLAGS) -B anon_main -o $(ANON_IREP) $(ANON_ENTRYPOINT)

$(BOOTSTRAP_IREP): $(BOOTSTRAP_ENTRYPOINT) $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	bin/mrbc $(MRBC_FLAGS) -B anon_bootstrap_main -o $(BOOTSTRAP_IREP) $(BOOTSTRAP_ENTRYPOINT)

$(SERVE_IREP): $(SERVE_ENTRYPOINT) $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	bin/mrbc $(MRBC_FLAGS) -B anon_serve_main -o $(SERVE_IREP) $(SERVE_ENTRYPOINT)

$(ANON_OBJ): main.c $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	$$(bin/mruby-config --cc) \
		$$(bin/mruby-config --cflags) \
		-DAPP_IREP=anon_main \
		-I $(BUILD_DIR)/include \
		-c main.c \
		-o $(ANON_OBJ)

$(BOOTSTRAP_OBJ): main.c $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	$$(bin/mruby-config --cc) \
		$$(bin/mruby-config --cflags) \
		-DAPP_IREP=anon_bootstrap_main \
		-I $(BUILD_DIR)/include \
		-c main.c \
		-o $(BOOTSTRAP_OBJ)

$(SERVE_OBJ): main.c $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	$$(bin/mruby-config --cc) \
		$$(bin/mruby-config --cflags) \
		-DAPP_IREP=anon_serve_main \
		-I $(BUILD_DIR)/include \
		-c main.c \
		-o $(SERVE_OBJ)

$(ANON_BIN): $(ANON_OBJ) $(ANON_IREP) $(TOOLCHAIN_STAMP) $(STANDALONE_FILES)
	mkdir -p bin
	$$(bin/mruby-config --ld) $(APP_LDFLAGS) -o $(ANON_BIN) \
		$(ANON_OBJ) \
		$(ANON_IREP) \
		$$(bin/mruby-config --ldflags-before-libs) \
		$(BUILD_DIR)/lib/libmruby.a \
		$$(bin/mruby-config --ldflags) \
		$$(bin/mruby-config --libs | sed 's/-lmruby//g')
	$(POST_BUILD) $(ANON_BIN)
	chmod 755 $(ANON_BIN)

$(BOOTSTRAP_BIN): $(BOOTSTRAP_OBJ) $(BOOTSTRAP_IREP) $(TOOLCHAIN_STAMP) $(STANDALONE_FILES)
	mkdir -p libexec/anon
	$$(bin/mruby-config --ld) $(APP_LDFLAGS) -o $(BOOTSTRAP_BIN) \
		$(BOOTSTRAP_OBJ) \
		$(BOOTSTRAP_IREP) \
		$$(bin/mruby-config --ldflags-before-libs) \
		$(BUILD_DIR)/lib/libmruby.a \
		$$(bin/mruby-config --ldflags) \
		$$(bin/mruby-config --libs | sed 's/-lmruby//g')
	$(POST_BUILD) $(BOOTSTRAP_BIN)
	chmod 755 $(BOOTSTRAP_BIN)

$(SERVE_BIN): $(SERVE_OBJ) $(SERVE_IREP) $(TOOLCHAIN_STAMP) $(STANDALONE_FILES)
	mkdir -p libexec/anon
	$$(bin/mruby-config --ld) $(APP_LDFLAGS) -o $(SERVE_BIN) \
		$(SERVE_OBJ) \
		$(SERVE_IREP) \
		$$(bin/mruby-config --ldflags-before-libs) \
		$(BUILD_DIR)/lib/libmruby.a \
		$$(bin/mruby-config --ldflags) \
		$$(bin/mruby-config --libs | sed 's/-lmruby//g')
	$(POST_BUILD) $(SERVE_BIN)
	chmod 755 $(SERVE_BIN)

clean:
	rm -f $(TOOLCHAIN_BIN)
	rm -f $(TOOLCHAIN_STAMP)
	rm -f $(STANDALONE_BINS) $(STANDALONE_IREPS) $(STANDALONE_OBJS)

distclean: clean
	rm -f $$(pwd)/*.lock
	rm -rf $(BUILD_DIR)
	rm -rf $(MRUBY_DIR)/build/repos/$(BUILD_NAME)

install: $(STANDALONE_BINS)
	mkdir -p $(DESTDIR)$(BINDIR) $(DESTDIR)$(LIBEXECDIR)
	install -m 755 $(ANON_BIN) $(DESTDIR)$(BINDIR)/anon
	install -m 755 $(BOOTSTRAP_BIN) $(DESTDIR)$(LIBEXECDIR)/bootstrap
	install -m 755 $(SERVE_BIN) $(DESTDIR)$(LIBEXECDIR)/serve
	if [ -d share ]; then \
		mkdir -p $(DESTDIR)$(SHAREDIR); \
		cp -R share/. $(DESTDIR)$(SHAREDIR)/; \
	fi

deinstall:
	rm -f $(DESTDIR)$(BINDIR)/anon
	rm -f $(DESTDIR)$(LIBEXECDIR)/bootstrap
	rm -f $(DESTDIR)$(LIBEXECDIR)/serve
	rm -rf $(DESTDIR)$(SHAREDIR)
