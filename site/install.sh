#!/usr/bin/env bash
git clone -b master git@github.com:picodotdev/alis.git
cd alis || exit
git config --local user.email "pico.dev@gmail.com"
git config --local user.name "pico.dev"

git clone -b gh-pages git@github.com:picodotdev/alis.git deploy/
cd deploy || exit
git config --local user.email "pico.dev@gmail.com"
git config --local user.name "pico.dev"

