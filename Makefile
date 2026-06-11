# Makefile for anonssh
#
# Prerequisites:
#   ../mruby    # mruby checkout (sibling directory)
#
# Quick start:
#   make        # build bin/anonssh and libexec/anonssh/{bootstrap,serve}
#   make clean  # clean build artifacts

MRUBY_DIR    ?= ../mruby
BUILD_CONFIG  = build.rb
BUILD_NAME    = anonssh
BUILD_DIR     = $(MRUBY_DIR)/build/$(BUILD_NAME)
RUBY_FILES   != find src mrblib -type f -name '*.rb' 2>/dev/null | sort

PREFIX      ?= /usr/local
BINDIR       = $(PREFIX)/bin
LIBEXECDIR    = $(PREFIX)/libexec/anonssh
SHAREDIR      = $(PREFIX)/share/$(BUILD_NAME)

ANONSSH_ENTRYPOINT        = src/bin/anonssh.rb
ANONSSH_BIN               = bin/anonssh
ANONSSH_IREP              = tmp/anonssh_main.c
ANONSSH_OBJ               = tmp/anonssh_main.o

BOOTSTRAP_ENTRYPOINT   = src/libexec/anonssh/bootstrap.rb
BOOTSTRAP_BIN          = libexec/anonssh/bootstrap
BOOTSTRAP_IREP         = tmp/anonssh_bootstrap_main.c
BOOTSTRAP_OBJ          = tmp/anonssh_bootstrap_main.o

SERVE_ENTRYPOINT       = src/libexec/anonssh/serve.rb
SERVE_BIN              = libexec/anonssh/serve
SERVE_IREP             = tmp/anonssh_serve_main.c
SERVE_OBJ              = tmp/anonssh_serve_main.o

STANDALONE_BINS        = $(ANONSSH_BIN) $(BOOTSTRAP_BIN) $(SERVE_BIN)
STANDALONE_IREPS       = $(ANONSSH_IREP) $(BOOTSTRAP_IREP) $(SERVE_IREP)
STANDALONE_OBJS        = $(ANONSSH_OBJ) $(BOOTSTRAP_OBJ) $(SERVE_OBJ)
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

$(ANONSSH_IREP): $(ANONSSH_ENTRYPOINT) $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	bin/mrbc $(MRBC_FLAGS) -B anonssh_main -o $(ANONSSH_IREP) $(ANONSSH_ENTRYPOINT)

$(BOOTSTRAP_IREP): $(BOOTSTRAP_ENTRYPOINT) $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	bin/mrbc $(MRBC_FLAGS) -B anonssh_bootstrap_main -o $(BOOTSTRAP_IREP) $(BOOTSTRAP_ENTRYPOINT)

$(SERVE_IREP): $(SERVE_ENTRYPOINT) $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	bin/mrbc $(MRBC_FLAGS) -B anonssh_serve_main -o $(SERVE_IREP) $(SERVE_ENTRYPOINT)

$(ANONSSH_OBJ): main.c $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	$$(bin/mruby-config --cc) \
		$$(bin/mruby-config --cflags) \
		-DAPP_IREP=anonssh_main \
		-I $(BUILD_DIR)/include \
		-c main.c \
		-o $(ANONSSH_OBJ)

$(BOOTSTRAP_OBJ): main.c $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	$$(bin/mruby-config --cc) \
		$$(bin/mruby-config --cflags) \
		-DAPP_IREP=anonssh_bootstrap_main \
		-I $(BUILD_DIR)/include \
		-c main.c \
		-o $(BOOTSTRAP_OBJ)

$(SERVE_OBJ): main.c $(TOOLCHAIN_STAMP)
	mkdir -p tmp
	$$(bin/mruby-config --cc) \
		$$(bin/mruby-config --cflags) \
		-DAPP_IREP=anonssh_serve_main \
		-I $(BUILD_DIR)/include \
		-c main.c \
		-o $(SERVE_OBJ)

$(ANONSSH_BIN): $(ANONSSH_OBJ) $(ANONSSH_IREP) $(TOOLCHAIN_STAMP) $(STANDALONE_FILES)
	mkdir -p bin
	$$(bin/mruby-config --ld) $(APP_LDFLAGS) -o $(ANONSSH_BIN) \
		$(ANONSSH_OBJ) \
		$(ANONSSH_IREP) \
		$$(bin/mruby-config --ldflags-before-libs) \
		$(BUILD_DIR)/lib/libmruby.a \
		$$(bin/mruby-config --ldflags) \
		$$(bin/mruby-config --libs | sed 's/-lmruby//g')
	$(POST_BUILD) $(ANONSSH_BIN)
	chmod 755 $(ANONSSH_BIN)

$(BOOTSTRAP_BIN): $(BOOTSTRAP_OBJ) $(BOOTSTRAP_IREP) $(TOOLCHAIN_STAMP) $(STANDALONE_FILES)
	mkdir -p libexec/anonssh
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
	mkdir -p libexec/anonssh
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
	install -m 755 $(ANONSSH_BIN) $(DESTDIR)$(BINDIR)/anonssh
	install -m 755 $(BOOTSTRAP_BIN) $(DESTDIR)$(LIBEXECDIR)/bootstrap
	install -m 755 $(SERVE_BIN) $(DESTDIR)$(LIBEXECDIR)/serve
	if [ -d share/$(BUILD_NAME) ]; then \
		mkdir -p $(DESTDIR)$(SHAREDIR); \
		cp -R share/$(BUILD_NAME)/. $(DESTDIR)$(SHAREDIR)/; \
	fi

deinstall:
	rm -f $(DESTDIR)$(BINDIR)/anonssh
	rm -f $(DESTDIR)$(LIBEXECDIR)/bootstrap
	rm -f $(DESTDIR)$(LIBEXECDIR)/serve
	rm -rf $(DESTDIR)$(SHAREDIR)
