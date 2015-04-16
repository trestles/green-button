# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

require 'tempfile'
require 'logger'
require 'greenbutton'
require 'faraday'
require 'data_mapper'
require 'dm-migrations'
require 'configurations'
require 'pvimpact/greenbutton/version'
require 'pvimpact/greenbutton/validation'
require 'pvimpact/greenbutton/model/electricity_power_usage_summary'
require 'pvimpact/greenbutton/model/interval_block'
require 'pvimpact/greenbutton/model/interval_reading'
require 'pvimpact/greenbutton/model/local_time_parameters'
require 'pvimpact/greenbutton/model/meter_reading'
require 'pvimpact/greenbutton/model/meter_reading_type'
require 'pvimpact/greenbutton/model/usage_point'
require 'pvimpact/greenbutton/model/aggregation_type'
require 'pvimpact/greenbutton/errors'
require 'pvimpact/greenbutton/parser'
require 'pvimpact/greenbutton/aggregator'

module PVImpactGreenButton
  extend PVImpactGreenButton::Validation
  include Configurations

  # This is the shared logger.
  LOGGER = Logger.new('greenbutton.log')

  # This is the configuration option for DB URL, default to 'postgres://localhost/pvimpact_greenbutton'
  configurable String, :db_url

  # Configure default options.
  configuration_defaults do |c|
    c.db_url = 'postgres://localhost/pvimpact_greenbutton'
  end

  # Public: Setup database for this gem.
  #
  # Raises PVImpactGreenButton::PersistenceError if failed to setup database
  def self.setup_db
    begin
      DataMapper.setup(:default, PVImpactGreenButton.configuration.db_url)
      DataMapper::Model.raise_on_save_failure = true
      DataMapper.finalize
    rescue => e
      LOGGER.fatal(e.backtrace)
      raise PVImpactGreenButton::PersistenceError, e.message
    end
  end

  # Public: Create database tables for this gem. NOTE that this method will wipe and re-create
  # the database tables.
  #
  # Raises PVImpactGreenButton::PersistenceError if failed to setup database
  def self.create_db
    setup_db
    DataMapper.auto_migrate!
  end

  # Public: Download customer GreenButton data from GreenButton API, apply aggregation if needed and then save
  # the data into database persistence.
  #
  # access_token - the OAuth2 access token String used to access the GreenButton API
  # resource_uri - the URI String of the resource to download
  # interval_start_time - the interval start Time, optional
  # interval_end_time - the interval end Time, optional
  # aggregation_type - the AggregationType, optional
  #
  # Returns the downloaded UsagePoint data
  #
  # Raises ArgumentError if access_token/resource_uri is nil or blank string or does not respond to to_s, or
  # interval_start_time/interval_end_time is not Time, or interval_start_time is later than interval_end_time,
  # or aggregation_type is not AggregationType
  # Raises PVImpactGreenButton::UnsupportedServiceKindError if any of the UsagePoint is for unsupported
  # service kind (currently only 0 - electricity is supported).
  # Raises PVImpactGreenButton::ParsingError if failed to parse the GreenButton data
  # Raises PVImpactGreenButton::AggregationError if failed to aggregate the GreenButton data
  # Raises PVImpactGreenButton::PersistenceError if failed to save GreenButton data into persistence
  def self.download_data(access_token, resource_uri, interval_start_time = nil, interval_end_time = nil, aggregation_type = nil)
    validate_string(access_token, 'access_token')
    validate_string(resource_uri, 'resource_uri')
    validate_time(interval_start_time, 'interval_start_time', false)
    validate_time(interval_end_time, 'interval_end_time', false)
    validate_time_range(interval_start_time, 'interval_start_time', interval_end_time, 'interval_end_time') if interval_start_time && interval_end_time
    validate_aggregation_type(aggregation_type, 'aggregation_type') if aggregation_type

    begin
      LOGGER.info("Send request to URL #{resource_uri}")
      # Fetch data from resource URI
      conn = Faraday.new(:url => resource_uri, :headers => { 'Authorization' => "Bearer #{access_token}"})

      # Apply date filters only if the resource has been downloaded before, discussions:
      # http://apps.topcoder.com/forums/?module=Thread&threadID=850470&start=0
      if UsagePoint.count(:subscription_id => resource_uri) > 0
        conn.params['published-min'] = interval_start_time.utc.iso8601 if interval_start_time
        conn.params['published-max'] = interval_end_time.utc.iso8601 if interval_end_time
        LOGGER.info("Using published-min #{conn.params['published-min']}")
        LOGGER.info("Using published-max #{conn.params['published-max']}")
      end

      response = conn.get
      raise PVImpactGreenButton::GreenButtonError, "GreenButton API responded with error code #{response.status}." unless response.status == 200

      # Create temporary file
      tempfile = Tempfile.new('download_data')
      LOGGER.info("Received GreenButton response #{response.body}")
      # Write response to temp file
      tempfile.write(response.body)
      tempfile.close
    rescue PVImpactGreenButton::GreenButtonError => e
      raise e
    rescue => e
      LOGGER.fatal(e.backtrace)
      raise PVImpactGreenButton::GreenButtonError, e.message
    end

    usage_points = nil
    # Begin transaction
    UsagePoint.transaction do |txn|
      begin
        # Parse response
        parser = Parser.new()
        parser.parse(tempfile.path, resource_uri)
        usage_points = parser.usage_points

        if usage_points.length == 0
          # Retrieve and update IntervalBlock's
          parser.interval_blocks.each do |interval_block|
            interval_block.save()
          end

          # Query from local persistence
          usage_points = retrieve_data(resource_uri, interval_start_time, interval_end_time, aggregation_type)
        else
          # For each usage point, perform aggregation and save in persistence
          usage_points.each do |usage_point|
            usage_point = Aggregator.aggregate(usage_point, aggregation_type)
            usage_point.meter_readings.each do |meter_reading|
              meter_reading.interval_blocks.each do |interval_block|
                interval_block.save
              end
              meter_reading.save
            end
            usage_point.save
          end
        end
      rescue DataMapper::SaveFailureError => e
        # Rollback transaction and raise PersistenceError
        LOGGER.fatal(e.backtrace)
        txn.rollback
        raise PVImpactGreenButton::PersistenceError, e.resource.errors.inspect
      ensure
        # Remove temp file
        tempfile.unlink
      end
    end
    return usage_points
  end

  # Public: Retrieve customer GreenButton data from database persistence, and apply aggregation if needed.
  #
  # subscription_id - the subscription ID String
  # interval_start_time - the interval start Time, optional
  # interval_end_time - the interval end Time, optional
  # aggregation_type - the AggregationType, optional
  #
  # Returns the persisted UsagePoint data
  #
  # Raises ArgumentError if subscription_id is nil or blank string or does not respond to to_s, or
  # interval_start_time/interval_end_time is not Time, or interval_start_time is later than interval_end_time,
  # or aggregation_type is not AggregationType
  # Raises PVImpactGreenButton::AggregationError if failed to aggregate the GreenButton data
  # Raises PVImpactGreenButton::PersistenceError if failed to save GreenButton data into persistence
  def self.retrieve_data(subscription_id, interval_start_time = nil, interval_end_time = nil, aggregation_type = nil)
    validate_string(subscription_id, 'subscription_id')
    validate_time(interval_start_time, 'interval_start_time', false)
    validate_time(interval_end_time, 'interval_end_time', false)
    validate_time_range(interval_start_time, 'interval_start_time', interval_end_time, 'interval_end_time') if interval_start_time && interval_end_time
    validate_aggregation_type(aggregation_type, 'aggregation_type') if aggregation_type

    begin
      # Query usage points from persistence
      interval_block_filter = {}
      interval_block_filter = interval_block_filter.merge({ :start_time.gte => interval_start_time }) if interval_start_time
      interval_block_filter = interval_block_filter.merge({ :end_time.lte => interval_end_time }) if interval_end_time
      usage_points = UsagePoint.all(
        :subscription_id => subscription_id,
        :meter_readings => {
          :interval_blocks => interval_block_filter
        }
      )
      # For each usage point, perform aggregation
      usage_points.each do |usage_point|
        Aggregator.aggregate(usage_point, aggregation_type)

        usage_point.meter_readings.each do |meter_reading|
          # Include only IntervalBlock's within the range
          meter_reading.interval_blocks = meter_reading.interval_blocks.all(interval_block_filter)
        end
      end

      return usage_points
    rescue DataMapper::PersistenceError, DataMapper::ObjectNotFoundError, DataMapper::UnknownRelationshipError => e
      raise PVImpactGreenButton::PersistenceError, e.message
    end
  end
end
