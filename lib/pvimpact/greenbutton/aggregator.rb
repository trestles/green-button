# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

module PVImpactGreenButton
  # Public: This module provides method to aggregate interval readings in a UsagePoint according
  # to given aggregation type.
  module Aggregator
    extend Validation

    # Public: Aggregates interval readings in a UsagePoint according to given aggregation type.
    #
    # usage_point - the UsagePoint to aggregate
    # aggregation_type - the AggregationType used to apply aggregation.
    #
    # Returns the aggregated UsagePoint
    #
    # Raises ArgumentError if usage_point is nil, or aggregation_type is not of type AggregationType
    # Raises PVImpactGreenButton::AggregationError if any error occurred during the aggregation process
    def self.aggregate(usage_point, aggregation_type = nil)
      validate_required(usage_point, 'usage_point')
      validate_aggregation_type(aggregation_type, 'aggregation_type') if aggregation_type

      # No further aggregation is required
      return usage_point if !aggregation_type || aggregation_type == AggregationType::DEFAULT

      # Iterate through all MeterReading's of the UsagePoint
      usage_point.meter_readings.each do |meter_reading|
        # Raise error if time_attribute isn't supported
        raise PVImpactGreenButton::AggregationError unless meter_reading.meter_reading_type.time_attribute.between?(0, 77)

        interval_length = meter_reading.meter_reading_type.aggregation_type == 0 ?
          meter_reading.meter_reading_type.interval_length : meter_reading.meter_reading_type.aggregation_type

        # (Validation)Iterate through all IntervalBlock's of the MeterReading
        meter_reading.interval_blocks.each do |interval_block|
          # Iterate through all IntervalReading's of the IntervalBlock
          interval_block.interval_readings.each do |interval_reading|
            # Validate missing/zero/NaN value/cost and mark as is_missing if needed
            interval_reading.value = nil if interval_reading.value == 0
            interval_reading.cost = nil if interval_reading.cost == 0
            interval_reading.is_missing = true if !interval_reading.value || !interval_reading.cost
          end
        end

        # Perform aggregation only if current interval length does not match aggregation type
        next unless interval_length != aggregation_type

        meter_reading.meter_reading_type.aggregation_type = aggregation_type

        begin
          if aggregation_type < interval_length
          # target interval is less than current interval length, divide current interval readings
          meter_reading.interval_blocks.each do |interval_block|
            interval_readings = [].push(*interval_block.interval_readings)
            interval_block.interval_readings = []

            interval_readings.each do |interval_reading|
              start_time = interval_reading.start_time
              avg_value = interval_reading.is_missing ? nil : interval_reading.value.to_f / interval_length
              avg_cost = interval_reading.is_missing ? nil : interval_reading.cost.to_f / interval_length
              (1..interval_length / aggregation_type).each do
                # Create new IntervalReading
                end_time = (start_time + aggregation_type).utc
                interval_block.interval_readings << IntervalReading.new(
                  {
                    :aggregation_type => aggregation_type,
                    :cost => avg_cost == nil ? avg_cost : avg_cost * aggregation_type,
                    :value => avg_value == nil ? avg_value : avg_value * aggregation_type,
                    :start_time => start_time,
                    :end_time => end_time,
                    :is_missing => interval_reading.is_missing
                  }
                )
                start_time = end_time
              end

              reminder = interval_length % aggregation_type
              interval_block.interval_readings << IntervalReading.new(
                {
                  :aggregation_type => aggregation_type,
                  :cost => avg_cost == nil ? avg_cost : avg_cost * reminder,
                  :value => avg_value == nil ? avg_value : avg_value * reminder,
                  :start_time => start_time,
                  :end_time => (start_time + reminder).utc,
                  :is_missing => interval_reading.is_missing
                }
              ) if reminder > 0
            end
          end

        else
          # target interval is greater than current interval length, aggregate current interval readings
          meter_reading.interval_blocks.each do |interval_block|
            start_time = nil
            total_value = 0
            total_cost = 0
            total_duration = 0
            interval_readings = [].push(*interval_block.interval_readings)
            interval_block.interval_readings = []

            # Iterate through all IntervalReading's of the IntervalBlock
            interval_readings.each do |interval_reading|
              start_time = interval_reading.start_time unless start_time
              # A new IntervalReading should be created
              if total_duration + interval_length >= aggregation_type
                # Accumulate part of the reading
                ratio = (aggregation_type - total_duration).to_f / interval_length
                total_value += ratio * interval_reading.value if interval_reading.value
                total_cost += ratio * interval_reading.cost if interval_reading.cost
                end_time = (start_time + aggregation_type).utc

                # Create new IntervalReading
                interval_block.interval_readings << IntervalReading.new(
                  {
                    :aggregation_type => aggregation_type,
                    :cost => total_cost,
                    :value => total_value,
                    :start_time => start_time,
                    :end_time => end_time
                  }
                )

                # Reset accumulating variables
                total_value = (1 - ratio) * interval_reading.value if interval_reading.value
                total_cost = (1 - ratio) * interval_reading.cost if interval_reading.cost
                total_duration = (1 - ratio) * interval_length
                start_time = end_time
              else
                # Continue accumulating
                total_value += interval_reading.value if interval_reading.value
                total_cost += interval_reading.cost if interval_reading.cost
                total_duration += interval_length
              end
            end

            # We may have still accumulated readings not added
            interval_block.interval_readings << IntervalReading.new(
              {
                :aggregation_type => aggregation_type,
                :cost => total_cost,
                :value => total_value,
                :start_time => start_time,
                :end_time => (start_time + total_duration).utc
              }
            ) if total_duration > 0
          end
        end
        rescue => e
          LOGGER.fatal(e.backtrace)
          raise PVImpactGreenButton::AggregationError, e.message
        end
      end
      usage_point
    end
  end
end