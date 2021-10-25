#!/usr/bin/env bash
set -e

cd deploy/
git add .
git commit -m "Site update at `LC_ALL=en_US.utf8 date +%Y-%m-%dT%H:%M:%S%z`"
git push origin gh-pages
cd ..
