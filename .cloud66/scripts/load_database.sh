### /.CLOUD66/SCRIPTS/LOAD_DATABASE.SH ###

cd $STACK_PATH
bundle exec rake db:create RAILS_ENV=production
bundle exec rake db:schema:load RAILS_ENV=production