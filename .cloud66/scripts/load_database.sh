### /.CLOUD66/SCRIPTS/LOAD_DATABASE.SH ###

cd $STACK_PATH
bundle exec rake db:create
bundle exec rake db:schema:load