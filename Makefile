.PHONY: changelog release local-setup

SEMTAG=.bin/semtag.sh

CHANGELOG_FILE=CHANGELOG.md

scope ?= "minor"

changelog-unrelease:
	git-chglog --no-case -o $(CHANGELOG_FILE)

changelog:
	git-chglog --no-case -o $(CHANGELOG_FILE) --next-tag `$(SEMTAG) final -s $(scope) -o -f`

release:
	$(SEMTAG) final -s $(scope)

local-setup:
	cat .tool-versions | cut -f 1 -d ' ' | xargs -n 1 asdf plugin-add || true
	asdf plugin-update --all
	asdf install
	asdf reshim
	pip install -r requirements.txt
	pre-commit install
	gitlint install-hook
