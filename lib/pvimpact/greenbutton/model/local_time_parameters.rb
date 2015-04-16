# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

module PVImpactGreenButton
  # Public: This class represents Local Time Parameters.
  class LocalTimeParameters
    include DataMapper::Resource

    # Public: Returns the String id.
    property :id, Text, :key => true

    # Public: Returns the DST end rule.
    property :dst_end_rule, String

    # Public: Returns the DST offset.
    property :dst_offset, Integer

    # Public: Returns the DST start rule.
    property :dst_start_rule, String

    # Public: Returns the timezone offset.
    property :tz_offset, Integer

    # Public: Returns the UsagePoint.
    belongs_to :usage_point
  end
end
