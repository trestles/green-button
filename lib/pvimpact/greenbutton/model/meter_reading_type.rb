# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

module PVImpactGreenButton
  # Public: This class represents Meter Reading Type.
  class MeterReadingType
    include DataMapper::Resource

    # Public: Returns the String id.
    property :id, Text, :key => true

    # Public: Returns the accumulation behaviour.
    property :accumulation_behaviour, Integer

    # Public: Returns the commodity.
    property :commodity, Integer

    # Public: Returns the currency.
    property :currency, Integer

    # Public: Returns the data qualifier.
    property :data_qualifier, Integer

    # Public: Returns the flow direction.
    property :flow_direction, Integer

    # Public: Returns the interval length.
    property :interval_length, Integer

    # Public: Returns the kind.
    property :kind, Integer

    # Public: Returns the phase.
    property :phase, Integer

    # Public: Returns the power of ten multiplier.
    property :power_of_ten_multiplier, Integer

    # Public: Returns the time attribute.
    property :time_attribute, Integer

    # Public: Returns the UOM.
    property :uom, Integer

    # Public: Returns the MeterReading.
    belongs_to :meter_reading

    # Public: Returns the aggregation type.
    property :aggregation_type, Integer
  end
end
