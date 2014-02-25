### /.CLOUD66/SCRIPTS/LOAD_DATABASE.SH ###

cd $STACK_PATH
bundle exec rake RAILS_ENV=production db:create 
bundle exec rake RAILS_ENV=production db:schema:load