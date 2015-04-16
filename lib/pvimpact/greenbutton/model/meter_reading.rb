# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

module PVImpactGreenButton
  # Public: This class represents Meter Reading.
  class MeterReading
    include DataMapper::Resource

    # Public: Returns the String id.
    property :id, Text, :key => true

    # Public: Returns the UsagePoint.
    belongs_to :usage_point

    # Public: Returns the MeterReadingType.
    has 1, :meter_reading_type

    # Public: Returns the IntervalBlock's.
    has n, :interval_blocks, :order => [ :start_time.asc ]
  end
end
