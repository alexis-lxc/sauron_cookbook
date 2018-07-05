# sauron_cookbook

The cookbook for deploying [sauron](https://github.com/alexis-lxc/sauron).

This cookbook has two recipes:

* app.rb => This is to install sauron app on a ubuntu machine, it fetches all dependencies and install them.
* postgresql_server.rb => This installs postgres server, setup root user with passowrd, create user for app with a password and also creates a database with service.


## Required Attributes:

### For recipe **app.rb** 

* app_name => name of the app e.g. sauron
* command_name =>  this is the command used to run service e.g puma -C /etc/puma/sauron.rb
* environment_variables => these are the env variables used by sauron e.g variables related to database, logging etc.
* sauron_script_location => this is the location of the script file which will have commands to be executed before we run the service.


### For recipe **postgresql_server**

* database_root_password
* app_db_user
* app_db_name
* app_db_name

### For recipe **redis_server**
* None

### For recipe **sidekiq**

Set the following env variables:

* SIDEKIQ_REDIS_URL
* SIDEKIQ_POLL_INTERVAL
* WAIT_INTERVAL_FOR_CONTAINER_OPERATIONS


## IMPORTANT

### This cookbook does not run migration, for now in order to run migration follow following:

* Login to the box one which service is running
* Go to the app user home directory and run the following commands:

```. /etc/default/sauron.conf.tmp && cd $HOME/$USER && bundle exec rake db:migrate```

### How to setup locally:

You need to have following installed:
* vagrant
* `gem install test-kitchen`


Now run the following commands:

* `kitchen create`
* `kitchen converge`

