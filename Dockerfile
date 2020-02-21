FROM instructure/ruby-passenger:2.6

ARG DEV_BUILD='false'
ENV APP_HOME /usr/src/app/

USER root
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && curl --silent https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update -y \
  && apt-get install -y \
    mysql-client-5.7 \
    postgresql-client-9.6 \
  && ([ "$DEV_BUILD" = 'true' ] \
    && apt-get install -y \
      libqt4-dev \
      libqtwebkit-dev \
      xvfb \
    || true ) \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY config/nginx/location.conf /usr/src/nginx/location.d/location.conf

RUN if [ "$DEV_BUILD" = 'true' ]; then echo 'docker ALL=(ALL) NOPASSWD: SETENV: /usr/sbin/update-ca-certificates' >> /etc/sudoers; fi

USER docker

COPY --chown=docker:docker Gemfile Gemfile.lock $APP_HOME

RUN if [ "$DEV_BUILD" = 'false' ]; then BUNDLER_ARGS='--without development test'; fi; \
  bundle install --jobs 8 $BUNDLER_ARGS

RUN mkdir -p tmp
COPY --chown=docker:docker . $APP_HOME

RUN RAILS_ENV=production \
    DATABASE_URL=postgres://user:pass@127.0.0.1/does_not_exist_dbname \
    LTI_KEY=12345 \
    LTI_SECRET=secret \
    CANVAS_KEY=1 \
    CANVAS_SECRET=secret \
    SECRET_KEY_BASE=fake \
    bundle exec rake assets:precompile

ENTRYPOINT [ "/usr/src/app/docker-entrypoint.sh" ]
