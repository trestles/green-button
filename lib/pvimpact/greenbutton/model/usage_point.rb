# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

module PVImpactGreenButton
  # Public: This class represents Usage Point.
  class UsagePoint
    include DataMapper::Resource

    # Public: Returns the String id.
    property :id, Text, :key => true

    # Public: Returns the kind
    property :kind, String

    # Public: Returns the subscription ID.
    property :subscription_id, Text

    # Public: Returns the MeterReading's.
    has n, :meter_readings

    # Public: Returns the LocalTimeParameters.
    has 1, :local_time_parameters

    # Public: Returns the ElectricityPowerUsageSummary records.
    has n, :electricity_power_usage_summaries
  end
end
