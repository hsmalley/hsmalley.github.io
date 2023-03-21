#!/bin/bash

# Set the vars
date=$(date '+%F')
repo=$(pwd)

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

function ipfs_publish() {
	# http://blog.techcabbage.xyz
	# http://ipfs.io/ipns/k51qzi5uqu5djjziu1k5ty1a4xo13pn4bs4at2hk0u6f9bdllv5k47bqvv0yz9
	# http://dweb.link/ipns/k51qzi5uqu5djjziu1k5ty1a4xo13pn4bs4at2hk0u6f9bdllv5k47bqvv0yz9
	# https://k51qzi5uqu5djjziu1k5ty1a4xo13pn4bs4at2hk0u6f9bdllv5k47bqvv0yz9.ipns.dweb.link/
	echo -e "\033[0;32mAdding to IPFS...\033[0m"
	ipfs add -r . >/dev/null 2>&1
	echo -e "\033[0;32mAdding to Public to IPFS...\033[0m"
	ipfs add -r site | tee ipfs_publish.log >/dev/null 2>&1
	echo -e "\033[0;32mPublishing to IPNS...\033[0m"
	HASH=$(tail -n 1 ipfs_publish.log | awk '{print $2}')
	ipfs name publish --key=blog "${HASH}" | tee -a ipfs_publish.log >/dev/null 2>&1
	echo -e "\033[0;32mPinning IPNS to local gateway...\033[0m"
	ipfs pin add -r /ipns/k51qzi5uqu5djjziu1k5ty1a4xo13pn4bs4at2hk0u6f9bdllv5k47bqvv0yz9 >/dev/null 2>&1
	echo -e "\033[0;32mDone\033[0m"
}

# Make sure everything builds correctly
mkdocs build
# Publish Site on IPFS
ipfs_publish
# Prep everything for GH-Pages
add_content && git_stuff || exit
# Deploy the site
mkdocs gh-deploy
