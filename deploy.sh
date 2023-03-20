#!/bin/bash

# Set the vars
date=$(date '+%F')
repo=$(PWD)

# Do the git stuff if needed
function git_stuff() {
	git switch main
	git commit -am "${date}"
	git push
}

# Add the content if needed
function add_content() {
	find docs -maxdepth 1 -type l | while IFS= read -r link; do
		cd "${link}" || exit
		git add ./*.md >/dev/null 2>&1
		git commit -am "${date}" >/dev/null 2>&1
		cd "${repo}" || exit
	done
}

# Prep everything to be built
add_content && git_stuff || exit
# Make sure everything builds correctly
mkdocs build || exit
# Deploy the site
mkdocs gh-deploy
