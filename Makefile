# ======================================================================
# Makefile - Converts Markdown to Jira Notation using Pandoc
#
# GitHub Flavored Markdown
#   https://help.github.com/articles/github-flavored-markdown/
# Jira Text Formatting Notation
#   https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa
# ======================================================================
SHELL = /bin/bash

# Commands
PANDOC = $(HOME)/opt/pandoc-2.7.3/bin/pandoc
RECODE = recode
SED = sed
TR = tr

# Command options
PANDOC_OPTS = --from=gfm --to=jira
RECODE_OPTS = html..utf-8

# Sed scripts
sed_hyphen = 's/&hyphen;/-/g'
sed_lowbar = 's/&lowbar;/_/g'
sed_utf8 = -e $(sed_hyphen) -e $(sed_lowbar)

sed_code_head = 's/\*\r\r{code}/*\r{code}/g'
sed_code_tail = 's/\r{code}\r\r/{code}\r\r/g'
sed_code_bash = 's/{code}\r\#!\/bin\/bash/{code:bash}\r\#!\/bin\/bash/g'
sed_double_nl = 's/\r\r\r/\r\r/g'
sed_tidy = -e $(sed_code_head) -e $(sed_code_tail) \
    -e $(sed_code_bash) -e $(sed_double_nl)

sed_images = 's/!images\//!/g'
sed_backslash = 's/ \\{/ {/'
sed_fixes = -e $(sed_images) -e $(sed_backslash)

# Translate commands - allows Sed to match patterns across newlines
n2r = $(TR) '\n' '\r'
r2n = $(TR) '\r' '\n'

# ======================================================================
# Pattern rules
# ======================================================================

%.tmp.jira: %.md
	$(PANDOC) $(PANDOC_OPTS) --output=$@ $<

%.utf8.jira: %.tmp.jira
	cat $< | $(RECODE) $(RECODE_OPTS) | $(SED) $(sed_utf8) > $@

%.tidy.jira: %.utf8.jira
	cat $< | $(n2r) | $(SED) $(sed_tidy) | $(r2n) > $@

%.jira: %.tidy.jira
	$(SED) $(sed_fixes) $< > $@

# ======================================================================
# Explicit rules
# ======================================================================

.PHONY: all clean

all: README.jira

clean:
	rm -f *.jira
