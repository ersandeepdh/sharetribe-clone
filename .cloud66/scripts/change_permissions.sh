#!/bin/bash
#load environment variables
source /var/.cloud66_env
#assign desired permissions
cd $RAILS_STACK_PATH/../ && sudo chmod 777 -R releases/