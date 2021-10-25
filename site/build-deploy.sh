#!/usr/bin/env bash
set -e

(cd deploy/ && git pull)
hugo --destination="deploy"
