FROM instructure/ruby-node-pg:2.2

ARG dev_build='false'
ENV APP_HOME /usr/src/app/

USER root
RUN apt-get update; \
  if [ "$dev_build" = 'true' ] ; then apt-get install -y libqt4-dev libqtwebkit-dev xvfb; fi \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && if [ -e /var/lib/gems/$RUBY_MAJOR.0/gems/bundler-* ]; then BUNDLER_INSTALL="-i /var/lib/gems/$RUBY_MAJOR.0"; fi \
  && gem uninstall --all --ignore-dependencies --force $BUNDLER_INSTALL bundler \
  && gem install bundler --no-document -v 1.15.3 \
  && gem update --system --no-document \
  && find $GEM_HOME ! -user docker | xargs chown docker:docker

WORKDIR $APP_HOME

COPY ./Gemfile $APP_HOME
COPY ./Gemfile.lock $APP_HOME
RUN chown -R docker:docker $APP_HOME

USER docker
RUN if [ "$dev_build" = 'false' ] ; then BUNDLER_ARGS='--without development test'; fi; \
  bundle install --jobs 8 $BUNDLER_ARGS

USER root
COPY . $APP_HOME
RUN chown -R docker:docker $APP_HOME

USER docker
RUN bundle exec rake assets:precompile RAILS_ENV=production LTI_KEY=12345 LTI_SECRET=secret

CMD ["bin/startup"]
