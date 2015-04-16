# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0
require 'dm-zone-types'

module PVImpactGreenButton
  # Public: This class represents Interval Block.
  class IntervalBlock
    include DataMapper::Resource

    # Public: Returns the String id
    property :id, Text, :key => true

    # Public: Returns the start time.
    property :start_time, ZonedTime

    # Public: Returns the end time.
    property :end_time, ZonedTime

    # Public: Returns the ID of the UsagePoint
    property :usage_point_id, Text

    # Public: Returns the IntervalReading's.
    has n, :interval_readings, :order => [ :start_time.asc ]

    # Public: Returns the MeterReading.
    belongs_to :meter_reading
  end
end
