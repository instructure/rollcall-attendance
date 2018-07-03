#!/bin/bash

set -e

docker --version
docker-compose --version

export COMPOSE_FILE=docker-compose.yml:docker-compose.test.yml
export RAILS_ENV=test

# clean up containers
docker-compose rm -fv

# build the containers
docker-compose build

# start the containers
docker-compose up -d db redis

# wait for postgres to start accepting connections
# TODO: actively check in a loop with a shorter sleep
sleep 5

set +e

# create and migrate the database
docker-compose run --rm web bundle exec rake db:setup

# run the tests
docker-compose run --user root --rm web bundle exec rake spec spec:javascript
rake_status=$?

docker-compose run --user root --rm web bundle exec brakeman
brake_status=$?

# run cucumber tests
docker-compose run --rm web bash bin/cucumber
cuke_status=$?

echo $rake_status
echo $brake_status
echo $cuke_status

if [ $rake_status != 0 -o $brake_status != 0 -o $cuke_status != 0 ]; then
  test_status=1
else
  test_status=0
fi

docker-compose stop

exit $test_status
