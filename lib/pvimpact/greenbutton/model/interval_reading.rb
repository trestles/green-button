# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0
require 'dm-zone-types'

module PVImpactGreenButton
  # Public: This class represents Interval Reading.
  class IntervalReading
    include DataMapper::Resource

    # Public: Returns the String id.
    property :id, Serial

    # Public: Returns the aggregation type.
    property :aggregation_type, Integer

    # Public: Returns the cost.
    property :cost, Float

    # Public: Returns the start time.
    property :start_time, ZonedTime

    # Public: Returns the end time.
    property :end_time, ZonedTime

    # Public: Returns the value.
    property :value, Float

    # Public: Returns the IntervalBlock's.
    belongs_to :interval_block

    # Public: Returns whether value is missing for this IntervalReading.
    property :is_missing, Boolean
  end
end
