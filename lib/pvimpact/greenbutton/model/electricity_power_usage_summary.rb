# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0
require 'dm-zone-types'

module PVImpactGreenButton
  # Public: This class represents Electricity Power Usage Summary.
  class ElectricityPowerUsageSummary
    include DataMapper::Resource

    # Public: Returns the String id.
    property :id, Text, :key => true

    # Public: Returns the duration.
    property :duration, Integer

    # Public: Returns the start time.
    property :start_time, ZonedTime

    # Public: Returns the bill last period.
    property :bill_last_period, Integer

    # Public: Returns the bill to date.
    property :bill_to_date, Integer

    # Public: Returns the cost additional last period.
    property :cost_additional_last_period, Integer

    # Public: Returns the currency.
    property :currency, Integer

    # Public: Returns the overall consumption last period power of ten multiplier.
    property :overall_consumption_last_period_power_of_ten_multiplier, Integer

    # Public: Returns the overall consumption last period UOM.
    property :overall_consumption_last_period_uom, Integer

    # Public: Returns the overall consumption last period value.
    property :overall_consumption_last_period_value, Integer

    # Public: Returns the current billing period overall consumption power of ten multiplier.
    property :current_billing_period_overall_consumption_power_of_ten_multiplier, Integer

    # Public: Returns the current billing period overall consumption UOM.
    property :current_billing_period_overall_consumption_uom, Integer

    # Public: Returns the current billing period overall consumption timestamp.
    property :current_billing_period_overall_consumption_timestamp, ZonedTime

    # Public: Returns the current billing period overall consumption value.
    property :current_billing_period_overall_consumption_value, Integer

    # Public: Returns the quality of reading.
    property :quality_of_reading, Integer

    # Public: Returns the status timestamp.
    property :status_time_stamp, ZonedTime

    # Public: Returns the UsagePoint.
    belongs_to :usage_point
  end
end