# PVImpact Green Button Gem

## Overview

The Green Button Standard is a secure way of transmitting energy usage information developed by the United States
Department of Energy.

This gem provides functionality to download Green Button XML formatted data from remote APIs, process the data and persist
the data in database; it also provides functionality to retrieve Green Button data persisted in database.

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
* Create PostgreSQL database ```pvimpact_greenbutton```
    * Open terminal/command line, run ```psql```
    * Run ```create database pvimpact_greenbutton;``` in the ```psql``` terminal


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

## Tests

[RSpec](http://rspec.info) tests are written for major code of the gem. The tests are organized under
```/pvimpact-greenbutton/spec``` directory.

Please check ```/pvimpact-greenbutton/spec/spec_helper.rb``` to change the ```db_url``` configuration option if needed.

Use the following commands to run tests (make sure you have PostgreSQL database server running):

    rspec

NOTE that the tests may take quite a while, because some test cases do aggregation to 15 minutes interval thus will generate
huge number of IntervalReading records into database.

The test coverage report can be found at ```/pvimpact-greenbutton/coverage/index.html```, current code coverage is 97.27%.

## Usage Examples

    require 'pvimpact-greenbutton'

    # Configure the gem
    PVImpactGreenButton.configure do |config|
      config.db_url = 'postgres://user:password@localhost/pvimpact_greenbutton'
    end

    # Create DB
    PVImpactGreenButton.create_db

    # Download Data without date range or aggregation
    usage_points = PVImpactGreenButton.download_data('688b026c-665f-4994-9139-6b21b13fbeee',
            'https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Batch/Subscription/5')

    # Download Data with date range and aggregation
    usage_points = PVImpactGreenButton.download_data('688b026c-665f-4994-9139-6b21b13fbeee',
        'https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Batch/Subscription/5',
        Time.new(2013, 1, 1), Time.new(2013, 3, 2), PVImpactGreenButton::AggregationType::ONE_DAY)

    # Retrieve persisted data without date range or aggregation
    usage_points = PVImpactGreenButton.retrieve_data('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Batch/Subscription/5')

    # Retrieve persisted data with date range and aggregation
    usage_points = PVImpactGreenButton.retrieve_data('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Batch/Subscription/5',
        Time.new(2013, 1, 1), Time.new(2013, 3, 2), PVImpactGreenButton::AggregationType::ONE_DAY)


## Documentations

All code are documented using [TomDoc](http://tomdoc.org), and the API documentations are generated using
[Yard](http://yardoc.org) with [yard-tomdoc](https://github.com/rubyworks/yard-tomdoc) plugin. You may find the
generated API documentations under directory ```/pvimpact-greenbutton/doc```.

You may regenerate the documentations by running ```yard --plugin tomdoc```

## Limitations

* This application currently supports 'electricity' Usage Points only.

## References

* [GreenButton](http://www.greenbuttondata.org)
* [GreenButton Developer Resources](http://www.greenbuttondata.org/developers/)