# Roll call via inst-cli 

### Set up roll call locally with inst-cly

Issue the following two commands from the root folder of the roll call repo

```
./inst-cli/build.sh
./inst-cli/setup.sh
```

#### Steps in the build and setup flow

1. `cp inst-cli/docker-compose/docker-compose.local.yml docker-compose.local.yml`
2. `cp inst-cli/config/initializers/session-store.rb config/initializers/session_store.rb`
3. `docker compose build`
4. `docker compose up -d`
5. `docker compose exec web bundle exec rake db:create`
6. `docker compose exec web bundle exec rake db:migrate`
