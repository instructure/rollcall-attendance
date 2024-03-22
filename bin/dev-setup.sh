#!/usr/bin/env bash

set -e

source bin/common
welcome

notice "Starting Roll Call Setup"

notice "Preparing Docker"
docker_compose down || true # delete network may fail due to http-proxy container
# os_specific_setup
# generate_docker_override

if [ "$ARCH" = arm64 ]; then
  notice 'arm64 detected'
  echo 'You will need to build docker images using the guide below:'
  echo 'https://docs.google.com/document/d/1cA99LHLVZ9-US67UfhNKltO9LtmkXlN-BuKTCNPGbso/edit?usp=sharing'
  docker_compose build --no-cache
else
  docker_compose build --pull
fi

notice "Running Bundle Install"
# docker_compose_run bundle install --with test development --without production

notice "Preparing Databases (${RAILS_ENV})"
docker_rake db:drop
docker_rake db:create
docker_rake db:migrate
docker_rake db:seed

bin/rails db:environment:set RAILS_ENV=test
notice "Migrating Databases (${RAILS_ENV})"
docker_rake db:drop
docker_rake db:create
# prevent migrate from creating as root
docker_compose_run touch log/test.log
docker_rake db:migrate
docker_rake db:seed

bin/rails db:environment:set RAILS_ENV=development
