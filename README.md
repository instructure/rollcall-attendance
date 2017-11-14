# Roll Call Attendance Tracker

## Dependencies

- Ruby 2.4
- PostgreSQL
- Redis

## Development setup

Roll Call can be run locally on your machine or with Docker. These instructions
assume you are using Docker.

### 1. Setup Canvas:

You need to have a local Canvas install running, and it needs to be in
docker (otherwise having rollcall post back to it will not work, it needs
a domain both it and the browser can reach).

Follow our general Docker setup here:
https://github.com/instructure/canvas-lms/blob/stable/doc/docker/getting_docker.md

And our Canvas in Docker setup here:
https://github.com/instructure/canvas-lms/blob/stable/doc/docker/developing_with_docker.md

Once you have a dockerized Canvas up and running, you need to add a developer
key to Canvas for rollcall to connect with. As an admin account, go to
`http://canvas.docker/accounts/<id>/developer_keys`, create one with a
`tool_id` of "rollcall" and a redirect url of
`http://rollcall.docker/canvas_oauth`. Once it's been created, get the
ID number (an integer) from the index page along with the token and add
them as `CANVAS_KEY` and `CANVAS_SECRET`, respectively, in `.env`.

### 2. Configure the LTI

The LTI will run in development without further configuration; however, some things like mail delivery (for attendance report exports) may not work. You can further configure the LTI by specifying environment variables in `.env`. Refer to `env.sample` for inspiration.

Some aspects (such as database and mail) can also be configured in the traditional Rails way of YAML files in the `config` directory. Refer to `config/database.yml.sample` and `config/mail.yaml.sample` for examples.

Note that in production you will want to make sure to configure the SMTP outgoing address parameter to an email address on your own domain; otherwise, your reports will be sent from "`Roll Call <notifications@instructure.com>`", which is most certainly not what you want.

### 3. Docker build + Database migrations:

Now you should be able to build your containers with:

    docker-compose build

You can get your database prepped for development with the normal
rake tasks, you just have to run them in the container:

    docker-compose run --rm web bundle install
    docker-compose run --rm web bundle exec rake db:create
    docker-compose run --rm web bundle exec rake db:migrate

### 4. Run it!

You should be able to start everything with:

    docker-compose up

This will start up 5 containers: a web process to hit with your browser, a worker process to 
consume jobs, a postgres data store, a redis cache, and a fakes3 server so you don't need 
AWS resources. When they're running, you can visit your app in the browser by going to:

`http://rollcall.docker`

### 5. Add Roll Call to Canvas:

In Canvas, go to Account >> Settings >> Apps, click "Add App", and use the following settings:

    Configuration Type: By URL
    Name: Roll Call
    Consumer Key: 12345
    Shared Secret: secret
    Config URL: http://rollcall.docker/configure.xml

You can change the consumer key and shared secret by overriding `LTI_KEY` and `LTI_SECRET`
in `docker-compose.yml`.

You're all set!

## Running Tests (With Docker!)

Rollcall has three test suites (RSpec, Cucumber, & Jasmine).

Make sure your test database is in the right state before trying to run them:

    docker-compose run --rm web bundle exec rake db:test:prepare

Now you can run your rspec tests in the web container like this:

    docker-compose run --rm web bundle exec rake spec

You can watch your jasmine specs run by starting your docker-compose config, and then navigating to the `./jasmine` directory:

    docker-compose up

And then visit in your browser: `http://rollcall.docker/jasmine`

but that kind of sucks for rerunning. Run your javascript tests from the command line like this:

    docker-compose run --rm web bundle exec rake jasmine:ci

Finally, you can run your cucumber tests, but it's kind of hacky.  For linux
(which the container is) you need to wrap a cucumber run in "xvfb-run" for
capybara-webkit to work correctly, but something in that process is
making output redirection not work right, so you won't see the output if you
just run "docker-compose run --rm web xvfb-run bundle exec cucumber".

We've found you can get around this by telling docker-compose you want it to run
a bash script, and having the bash script kick off the xvfb-run command,
so run this to see your cuke output:

    docker-compose run --rm web bash bin/cucumber

#### Running the Whole Suite

If you want to run the whole suite of tests, like a CI would, just run:

    ./build.sh

and watch the output fly by. It builds the docker image and runs in sequence the rspec tests,
the jasmine tests, and the cukes. Failures in any should exit the script with a non-zero exit code.

### Avatars

You can enable or disable the avatars service in Canvas via the Rails console in `canvas-lms`:

    # from the canvas-lms directory
    docker-compose run --rm web bundle exec rails c

    Account.find_each { |a| a.enable_service(:avatars) ; a.save }
    - or -
    Account.find_each { |a| a.disable_service(:avatars) ; a.save }
