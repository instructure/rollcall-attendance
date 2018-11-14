FROM instructure/ruby-passenger:2.4-xenial

ARG dev_build='false'
ENV APP_HOME /usr/src/app/

USER root
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && curl --silent https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update --quiet=2 \
  && apt-get install --quiet=2 postgresql-client-9.6 mysql-client-5.6 tmux> /dev/null; \
  if [ "$dev_build" = 'true' ] ; then apt-get install --quiet=2 libqt4-dev libqtwebkit-dev xvfb; fi \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY config/nginx/location.conf /usr/src/nginx/location.d/location.conf

USER docker

COPY --chown=docker:docker Gemfile Gemfile.lock $APP_HOME

RUN if [ "$dev_build" = 'false' ] ; then BUNDLER_ARGS='--without development test'; fi; \
  bundle install --jobs 8 $BUNDLER_ARGS

COPY --chown=docker:docker . $APP_HOME

RUN RAILS_ENV=production \
    DATABASE_URL=postgres://user:pass@127.0.0.1/does_not_exist_dbname \
    LTI_KEY=12345 \
    LTI_SECRET=secret \
    CANVAS_KEY=1 \
    CANVAS_SECRET=secret \
    SECRET_KEY_BASE=fake \
    bundle exec rake assets:precompile

CMD ["/tini", "--", "bin/startup"]
