#!/bin/bash

realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

src_dir=$(dirname $(dirname $(realpath "$0")))"/.circleci"

output=$(
  ${BASH_SOURCE%/*}/../nancy run \
    --commands-after-container-init "exit 1" \
    --db-pgbench "-s 1" \
    --workload-pgbench "-t 1" 2>&1
)

if [[ $output =~ "Check artifacts to understand the reasons." ]]; then
  echo -e "\e[36mOK\e[39m"
else
  >&2 echo -e "\e[31mFAILED\e[39m"
  >&2 echo -e "Output: $output"
  exit 1
fi
