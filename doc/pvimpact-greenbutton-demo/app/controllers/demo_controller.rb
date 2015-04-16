# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

require 'pvimpact-greenbutton'

# Public: This is the controller to serve demo.
class DemoController < ApplicationController
  # Public: Returns the usage points.
  attr_accessor :usage_points
  # Public: Returns the operation
  attr_accessor :operation
  # Public: Returns the resource URI.
  attr_accessor :resource_uri
  # Public: Returns the access token.
  attr_accessor :access_token
  # Public: Returns the aggregation type.
  attr_accessor :aggregation_type
  # Public: Returns the interval start time.
  attr_accessor :interval_start_time
  # Public: Returns the interval end time.
  attr_accessor :interval_end_time
  # Public: Returns the error.
  attr_accessor :error

  # Public: Convert time string to time.
  # time_string - the time string
  # Returns the converted time
  def convert_time(time_string)
    parts = time_string.to_s.split('/')
    return parts.length == 3 ? Time.new(parts[2].to_i, parts[0].to_i, parts[1].to_i) : nil
  end

  # Public: Serve the demo.
  def index
    @operation = request.request_parameters['operation'].blank? ? nil : request.request_parameters['operation']
    @resource_uri = request.request_parameters['resource_uri'].blank? ? nil : request.request_parameters['resource_uri']
    @access_token = request.request_parameters['access_token'].blank? ? nil : request.request_parameters['access_token']
    @aggregation_type = request.request_parameters['aggregation_type'].blank? ? nil : request.request_parameters['aggregation_type']
    @interval_start_time = convert_time(request.request_parameters['interval_start_time'])
    @interval_end_time = convert_time(request.request_parameters['interval_end_time'])

    begin
      if !resource_uri.to_s.blank?
        if 'download_data' == operation
          @usage_points = PVImpactGreenButton.download_data(@access_token, @resource_uri, @interval_start_time, @interval_end_time, @aggregation_type.to_i)
        else
          @usage_points = PVImpactGreenButton.retrieve_data(@resource_uri, @interval_start_time, @interval_end_time, @aggregation_type.to_i)
        end
      end
    rescue => e
      @error = e
      p e.backtrace
    end
  end
end
