# PVImpact Green Button Gem Demo

## Overview

The Green Button Standard is a secure way of transmitting energy usage information developed by the United States
Department of Energy.

This gem provides functionality to download Green Button XML formatted data from remote APIs, process the data and persist
the data in database; it also provides functionality to retrieve Green Button data persisted in database.

This is the demo app for the ```pvimpact-greenbutton``` gem.

## Setup Prerequisites

* [PostgreSQL 9.4](http://www.postgresql.org)
* [Ruby 2.1.5](http://www.ruby-lang.org)
* [RubyGems 2.x](https://rubygems.org)
* [Ruby on Rails 3.2](http://rubyonrails.org)
* [Yard](http://yardoc.org) - for generating documentation
* [yard-tomdoc](https://github.com/rubyworks/yard-tomdoc) - for generating documentation
* [Bundler](http://bundler.io) - for building
* [RSpec](http://rspec.info) - for testing

### PostgreSQL

PostgreSQL database server can be downloaded from [here](http://www.postgresql.org/download/).

Alternatively,

* on Linux, you may run ```apt-get install postgresql-9.4``` to install
    * If you encounter error afterwards when executing ```bundle install``` for ```do_postgres``` gem,
      please install the dev version instead ```apt-get install postgresql-9.3 postgresql-server-dev-9.3 libpq-dev```,
      for more information refer to [https://github.com/datamapper/do/issues/66](https://github.com/datamapper/do/issues/66)
* on OS X, you may install it using [homebrew](http://brew.sh) ```brew install postgresql```

### Ruby

Ruby can be downloaded from [here](https://www.ruby-lang.org/en/downloads/).

Alternatively, you can use [rvm](https://rvm.io) to manage different Ruby versions: ```rvm install 2.1.5```

Alternatively,

* on Linux, you may run ```apt-get install ruby-full```
* on OS X, ruby 2.0 is pre-installed, but you may install 2.1.5 using [homebrew](http://brew.sh) ```brew install ruby```

### RubyGems

RubyGems can be downloaded from [here](https://rubygems.org/pages/download).

### Ruby on Rails

Ruby on Rails can be downloaded from [here](http://rubyonrails.org/download/).

Alternatively, you may run ```gem install rails``` to install.

### Yard and yard-tomdoc

Yard can be downloaded from [here](http://yardoc.org)

Alternatively, you may run ```gem install yard``` to install Yard, and run ```gem install yard-tomdoc``` to install yard-tomdoc.

### Bundler

Bundler can be downloaded from [here](http://bundler.io).

Alternatively, you may run ```gem install bundler``` to install.

### RSpec

RSpec can be downloaded from [here](http://rspec.info).

Alternatively, you may run ```gem install rspec``` to install.


## Installation Instructions

### Gem

* Open terminal/command line, go to directory ```/pvimpact-greenbutton```
* Run command ```bundle install``` to build the gem

### Demo Application
* Make sure you have all prerequisites installed on your system.
* Make sure you have started PostgreSQL database (e.g. ```postgres -D /usr/local/pgsql/data```)
* Create PostgreSQL database ```pvimpact_greenbutton_demo```
    * Open terminal/command line, run ```psql```
    * Run ```create database pvimpact_greenbutton_demo;``` in the ```psql``` terminal
* (Optional) Adjust the database connection information in ```/config/application.rb```
* Open terminal/command line, go to directory ```/pvimpact-greenbutton-demo```.
* Run command ```bundle install``` to install dependencies and build the application.
* Run command ```rails server``` to start the application

Now the application should be running at ```http://0.0.0.0:3000/demo/index```, and you should see messages like the following in console:

    [2015-03-28 01:51:51] INFO  WEBrick 1.3.1
    [2015-03-28 01:51:51] INFO  ruby 2.1.2 (2014-05-08) [x86_64-darwin14.0]
    [2015-03-28 01:51:51] INFO  WEBrick::HTTPServer#start: pid=66750 port=3000

## Usage Examples

You may now open browser to visit ```http://0.0.0.0:3000/demo/index```, and test the gem functionality using the UI. The pre-filled
Resource URI and Access Token should be working.