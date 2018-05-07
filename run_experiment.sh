#!/bin/bash
PG_VERSION="${PG_VERSION:-10}"
PROJECT="${PROJECT:-postila_ru}"
CURRENT_TS=$(date +%Y%m%d_%H%M%S_%Z)
DOCKER_MACHINE="${DOCKER_MACHINE:-nancy-$PROJECT-$CURRENT_TS}"
DOCKER_MACHINE="${DOCKER_MACHINE//_/-}"
EC2_TYPE="${EC2_TYPE:-r4.large}"
EC2_PRICE="${EC2_PRICE:-0.0315}"
EC2_KEY_PAIR=${EC2_KEY_PAIR:-awskey}
EC2_KEY_PATH=${EC2_KEY_PATH:-/Users/nikolay/.ssh/awskey.pem}
S3_BUCKET="${S3_BUCKET:-p-dumps}"

set -ueo pipefail
set -ueox pipefail # to debug

docker-machine create --driver=amazonec2 --amazonec2-request-spot-instance \
  --amazonec2-keypair-name="$EC2_KEY_PAIR" --amazonec2-ssh-keypath="$EC2_KEY_PATH" \
  --amazonec2-instance-type=$EC2_TYPE --amazonec2-spot-price=$EC2_PRICE $DOCKER_MACHINE

eval $(docker-machine env $DOCKER_MACHINE)

containerHash=$(docker `docker-machine config $DOCKER_MACHINE` run --name="pg_nancy" -dit "950603059350.dkr.ecr.us-east-1.amazonaws.com/nancy:pg96_$EC2_TYPE")
dockerConfig=$(docker-machine config $DOCKER_MACHINE)

function cleanup {
  cmdout=$(docker-machine rm --force $DOCKER_MACHINE)
  echo "Finished working with machine $DOCKER_MACHINE, termination requested, current status: $cmdout"
}
trap cleanup EXIT

shopt -s expand_aliases
alias s='docker $dockerConfig exec -it pg_nancy '

s "ps ax"

sleep 600

echo Bye!
