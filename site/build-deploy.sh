#!/usr/bin/env bash
set -eu

(cd deploy/ && git pull)
hugo gen chromastyles --style=github > themes/alis/static/assets/syntax.css
hugo --destination="deploy"
