web: bundle exec thin start -p ${PORT:-`cat .port`} -e ${RACK_ENV:-development}
worker: env RAILS_ENV=${RAILS_ENV:-development} QUEUE=* bundle exec rake resque:work
