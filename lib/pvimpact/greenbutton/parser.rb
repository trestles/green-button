# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

require 'greenbutton'

module PVImpactGreenButton
  # Public: Parser is used to parse GreenButton API data.
  class Parser
    include Validation

    # Public: Returns the parsed IntervalBlock's.
    attr_accessor :interval_blocks

    # Public: Returns the parsed UsagePoint's.
    attr_accessor :usage_points

    # Private: Fill IntervalReading's to an IntervalBlock.
    #
    # gb_interval_block - the IntervalBlock object from GreenButton gem
    # interval_block - the IntervalBlock object from this gem
    #
    # Returns the IntervalBlock with readings filled
    private
    def fill_interval_readings(gb_interval_block, interval_block)
      interval_block.interval_readings.destroy if interval_block.interval_readings && !interval_block.interval_readings.empty?
      gb_interval_block.doc.xpath("//entry[id='#{gb_interval_block.id}']/content/IntervalBlock/IntervalReading").each do |ir_element|
        start_time = Time.at(ir_element.xpath('./timePeriod/start').text.to_i).utc
        interval_block.interval_readings.new(
          {
            :aggregation_type => nil,
            :cost => ir_element.xpath('./cost').text.to_f,
            :value => ir_element.xpath('./value').text.to_f,
            :start_time => start_time,
            :end_time => (start_time + ir_element.xpath('./timePeriod/duration').text.to_i).utc
          }
        )
      end
      return interval_block
    end


    public
    # Public: Parse GreenButton data from given file.
    #
    # path - The String file path of the GreenButton API data
    # subscription_id - The String ID of the subscription from which the GreenButton data is being parsed
    #
    # Raises ArgumentError if path/subscription_id is nil or blank string
    # Raises PVImpactGreenButton::UnsupportedServiceKindError if any of the UsagePoint is for unsupported
    # service kind (currently only 0 - electricity is supported).
    # Raises PVImpactGreenButton::ParsingError if failed to parse the GreenButton data
    def parse(path, subscription_id)
      validate_string(path, 'path')
      validate_string(subscription_id, 'subscription_id')
      begin
        # Parse using GreenButton gem
        gb = GreenButton.load_xml_from_file(path)

        @interval_blocks = []

        # Adapt GreenButton object data to local models
        @usage_points = []
        gb.usage_points.each do |gb_usage_point|
          raise PVImpactGreenButton::UnsupportedServiceKindError if gb_usage_point.service_kind != :electricity
          usage_point = UsagePoint.first_or_new(
            { :id => gb_usage_point.href },
            {
              :id => gb_usage_point.href,
              :kind => gb_usage_point.service_kind,
              :subscription_id => subscription_id
            }
          )

          usage_point.local_time_parameters = LocalTimeParameters.first_or_new(
            {
              :id => gb_usage_point.local_time_parameters.href
            },
            {
              :id => gb_usage_point.local_time_parameters.href,
              :dst_end_rule => gb_usage_point.local_time_parameters.dst_end_rule,
              :dst_offset => gb_usage_point.local_time_parameters.dst_offset,
              :dst_start_rule => gb_usage_point.local_time_parameters.dst_start_rule,
              :tz_offset => gb_usage_point.local_time_parameters.tz_offset
            }
          )

          gb_usage_point.meter_readings.each do |gb_meter_reading|
            meter_reading = usage_point.meter_readings.first_or_new(
              {
                :id => gb_meter_reading.href
              },
              {
                :id => gb_meter_reading.href,
                :meter_reading_type => MeterReadingType.first_or_new(
                  {
                    :id => gb_meter_reading.reading_type.href
                  },
                  {
                    :id => gb_meter_reading.reading_type.href,
                    :accumulation_behaviour => gb_meter_reading.reading_type.accumulation_behaviour,
                    :commodity => gb_meter_reading.reading_type.commodity,
                    :currency => gb_meter_reading.reading_type.currency,
                    :data_qualifier => gb_meter_reading.reading_type.data_qualifier,
                    :flow_direction => gb_meter_reading.reading_type.flow_direction,
                    :interval_length => gb_meter_reading.reading_type.interval_length,
                    :kind => gb_meter_reading.reading_type.kind,
                    :phase => gb_meter_reading.reading_type.phase,
                    :power_of_ten_multiplier => gb_meter_reading.reading_type.power_of_ten_multiplier,
                    :time_attribute => gb_meter_reading.reading_type.time_attribute,
                    :uom => gb_meter_reading.reading_type.uom,
                    :aggregation_type => 0
                  }
                ),
              }
            )

            gb_meter_reading.interval_blocks.each do |gb_interval_block|
              interval_block = meter_reading.interval_blocks.first_or_new(
                {
                  :id => gb_interval_block.href
                },
                {
                  :id => gb_interval_block.href,
                  :start_time => gb_interval_block.start_time,
                  :end_time => gb_interval_block.end_time,
                  :usage_point_id => usage_point.id,
                }
              )

              fill_interval_readings(gb_interval_block, interval_block)
            end
          end

          gb_usage_point.electric_power_usage_summaries.each do |gb_epus|
            usage_point.electricity_power_usage_summaries.first_or_new(
            {
                :id => gb_epus.href
              },
              {
                :id => gb_epus.href,
                :duration => gb_epus.bill_duration,
                :start_time => gb_epus.bill_start,
                :bill_last_period => gb_epus.bill_last_period,
                :bill_to_date => gb_epus.bill_to_date,
                :cost_additional_last_period => gb_epus.cost_additional_last_period,
                :currency => gb_epus.currency,
                :overall_consumption_last_period_power_of_ten_multiplier => gb_epus.last_power_ten,
                :overall_consumption_last_period_uom => gb_epus.last_uom,
                :overall_consumption_last_period_value => gb_epus.last_value,
                :current_billing_period_overall_consumption_power_of_ten_multiplier => gb_epus.current_power_ten,
                :current_billing_period_overall_consumption_uom => gb_epus.current_uom,
                :current_billing_period_overall_consumption_timestamp => gb_epus.current_timestamp,
                :current_billing_period_overall_consumption_value => gb_epus.current_value,
                :quality_of_reading => gb_epus.quality_of_reading,
                :status_time_stamp => Time.at(gb_epus.status_time_stamp.to_i).utc
              }
            )
          end

          @usage_points << usage_point
        end

        if @usage_points.empty?
          # No UsagePoint's parsed
          @interval_blocks = []
          gb.doc.xpath('//IntervalBlock').each do |ibe|
            gb_interval_block = GreenButtonClasses::IntervalBlock.new(ibe.parent.parent, gb)
            interval_block = IntervalBlock.first_or_new(
              {
                :id => gb_interval_block.href
              },
              {
                :id => gb_interval_block.href,
                :start_time => gb_interval_block.start_time,
                :end_time => gb_interval_block.end_time,
              }
            )
            @interval_blocks << fill_interval_readings(gb_interval_block, interval_block)
          end
        end
      rescue PVImpactGreenButton::UnsupportedServiceKindError => e
        raise e
      rescue => e
        LOGGER.fatal(e.backtrace)
        raise PVImpactGreenButton::ParsingError, e.message
      end
    end
  end
end
