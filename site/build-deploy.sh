#!/usr/bin/env bash
set -eu

(cd deploy/ && git pull)
hugo gen chromastyles --style=github > themes/alis/assets/syntax.css
hugo --destination="deploy" --gc --cleanDestinationDir
