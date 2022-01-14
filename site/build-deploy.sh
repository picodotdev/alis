#!/usr/bin/env bash
set -eu$

(cd deploy/ && git pull)
hugo --destination="deploy"
