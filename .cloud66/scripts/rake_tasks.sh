#!/bin/bash
# access your Rails stack path
cd $RAILS_STACK_PATH
bundle exec rake sharetribe:generate_customization_stylesheets RAILS_ENV=production
bundle exec rake assets:precompile:all RAILS_ENV=production RAILS_GROUPS=assets