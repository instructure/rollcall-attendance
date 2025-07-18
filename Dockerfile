FROM --platform=linux/amd64 instructure/ruby-passenger:3.3
ARG DEV_BUILD='false'
ENV APP_HOME /usr/src/app/

USER root
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && curl --silent https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update -y \
  && apt-get install -y \
  mariadb-client-10.3 \
  postgresql-client-13 \
  nodejs \
  && ([ "$DEV_BUILD" = 'true' ] \
  && apt-get install -y \
  libqt4-dev \
  libqtwebkit-dev \
  || true ) \
  && apt-get clean \
  && rm -rf \
  /tmp/* \
  /var/lib/apt/lists/* \
  /var/tmp/*

RUN if [ "$DEV_BUILD" = 'true' ]; then apt-get update && apt-get install -y xvfb; fi

# Install Firefox
RUN apt-get update -y && apt-get install -y firefox && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install wget && \
  wget -q https://github.com/mozilla/geckodriver/releases/download/v0.17.0/geckodriver-v0.17.0-linux64.tar.gz \
  && tar -zxvf geckodriver-v0.17.0-linux64.tar.gz \
  && chmod +x geckodriver \
  && mv geckodriver /usr/local/bin/geckodriver \
  && rm geckodriver-v0.17.0-linux64.tar.gz

COPY config/nginx/location.conf /usr/src/nginx/location.d/location.conf

# Allow certificate updates in dev
RUN if [ "$DEV_BUILD" = 'true' ]; then \
      echo 'docker ALL=(ALL) NOPASSWD: SETENV: /usr/sbin/update-ca-certificates' >> /etc/sudoers; \
    fi

RUN apt-get update && apt-get install -y build-essential g++\
  libxml2-dev libxslt1-dev zlib1g-dev \
  patch git \
  bzip2 xz-utils \
  phantomjs

USER docker

COPY --chown=docker:docker Gemfile Gemfile.lock $APP_HOME

RUN gem install bundler -v 2.4.16

RUN bundle lock --add-platform ruby
RUN bundle lock --add-platform x86_64-linux

RUN bundle config build.nokogiri --use-system-libraries
RUN bundle config build.phantomjs --use-system-libraries

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

USER root
RUN rm /etc/nginx/modules-enabled/50-mod-http-lua.conf
ENTRYPOINT [ "/usr/src/app/docker-entrypoint.sh" ]
