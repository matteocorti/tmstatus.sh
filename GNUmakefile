SCRIPT=tmstatus.sh
VERSION=`cat VERSION`
DIST_DIR=$(SCRIPT)-$(VERSION)
DIST_FILES=AUTHORS LICENSE ChangeLog Makefile NEWS.md README.md VERSION $(SCRIPT) COPYRIGHT tmstatus.sh.completion COPYING
YEAR=`date +"%Y"`
MONTH_YEAR=`date +"%B, %Y"`
FORMATTED_FILES=AUTHORS LICENSE ChangeLog Makefile NEWS.md README.md VERSION $(SCRIPT) COPYRIGHT tmstatus.sh.completion
SCRIPTS=*.sh

dist: version_check
	rm -rf $(DIST_DIR) $(DIST_DIR).tar.gz
	mkdir $(DIST_DIR)
	cp -r $(DIST_FILES) $(DIST_DIR)
# avoid to include extended attribute data files
# see https://superuser.com/questions/259703/get-mac-tar-to-stop-putting-filenames-in-tar-archives
	env COPYFILE_DISABLE=1 tar cfz $(DIST_DIR).tar.gz  $(DIST_DIR)
	env COPYFILE_DISABLE=1 tar cfj $(DIST_DIR).tar.bz2 $(DIST_DIR)

version_check:
	grep -q "VERSION\ *=\ *[\'\"]*$(VERSION)" $(SCRIPT)
	grep -q "${VERSION}" NEWS.md
	echo "Version check: OK"

# we check for tabs
# and remove trailing blanks
formatting_check:
	! grep -q '[[:blank:]]$$' $(FORMATTED_FILES)

SHFMT= := $(shell command -v shfmt 2> /dev/null)
format:
ifndef SHFMT
	echo "No shfmt installed"
else
# -p POSIX
# -w write to file
# -s simplify
# -i 4 indent with 4 spaces
	shfmt -p -w -s -i 4 $(SCRIPTS)
endif

clean:
	rm -f *~

distclean: clean
	rm -rf $(SCRIPT)-[0-9]*

SHELLCHECK := $(shell command -v shellcheck 2> /dev/null)

distcheck: disttest
disttest: dist formatting_check copyright_check shellcheck

COMPLETIONS_DIR := $(shell pkg-config --variable=completionsdir bash-completion)
install_bash_completion:
ifdef COMPLETIONS_DIR
	cp tmstatus.sh.completion $(COMPLETIONS_DIR)/tmstatus.sh
endif

install:
	cp tmstatus.sh /usr/local/bin

shellcheck:
ifndef SHELLCHECK
	echo "No shellcheck installed: skipping check"
else
	if shellcheck --help 2>&1 | grep -q -- '-o\ ' ; then shellcheck -o all $(SCRIPTS) ; else shellcheck $(SCRIPTS) ; fi
endif

CODESPELL := $(shell command -v codespell 2> /dev/null )
# spell check
codespell:
ifndef CODESPELL
	echo "no codespell installed"
else
	codespell \
	.
endif


copyright_check:
	grep -q "&copy; Matteo Corti, 2018-$(YEAR)" README.md
	grep -q "Copyright (c) 2018-$(YEAR) Matteo Corti" COPYRIGHT
	grep -q "Copyright (c) 2018-$(YEAR) Matteo Corti <matteo@corti.li>" $(SCRIPT)
	echo "Copyright year check: OK"

.PHONY: clean distclean codespell
