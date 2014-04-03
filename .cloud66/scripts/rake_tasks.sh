#!/bin/bash
# access your Rails stack path
cd $RAILS_STACK_PATH
# run your rake task
bundle exec rake sharetribe:generate_customization_stylesheets RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production