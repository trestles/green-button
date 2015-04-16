# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0
require 'spec_helper'

# Tests on Aggregator
describe PVImpactGreenButton::Aggregator do
  # Setup environment.
  before do
    @parser = PVImpactGreenButton::Parser.new()
    @parser.parse('spec/fixtures/case_15_months_daily_interval.xml', 'test')
    @usage_points = @parser.usage_points
    @usage_points.first.save
  end

  # Test on aggregate with nil usage_point
  describe 'aggregate with nil usage_point' do
    it 'should fail' do
      expect { PVImpactGreenButton::Aggregator.aggregate(nil, PVImpactGreenButton::AggregationType::ONE_MONTH) }.to raise_error(ArgumentError)
    end
  end

  # Test on aggregate with invalid aggregation_type
  describe 'aggregate with invalid aggregation_type' do
    it 'should fail' do
      expect { PVImpactGreenButton::Aggregator.aggregate(@usage_points.first, 'not valid') }.to raise_error(ArgumentError)
    end
  end

  # Test on aggregate with nil aggregation_type
  describe 'aggregate with nil aggregation_type' do
    it 'should be successful' do
      aggregated_usage_point = PVImpactGreenButton::Aggregator.aggregate(@usage_points.first)

      expect(aggregated_usage_point.subscription_id).to eq('test')
      expect(aggregated_usage_point.kind).to eq('electricity')
      expect(aggregated_usage_point.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(aggregated_usage_point.local_time_parameters).not_to eq(nil)
      expect(aggregated_usage_point.electricity_power_usage_summaries).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.length).to eq(1)
      expect(aggregated_usage_point.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks.length).to eq(15)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..14).each do |i|
        expect(aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(expected_interval_reading_counts[i])
        aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on aggregate with ONE_HOUR aggregation_type
  describe 'aggregate with ONE_HOUR aggregation_type' do
    it 'should be successful' do
      aggregated_usage_point = PVImpactGreenButton::Aggregator.aggregate(@usage_points.first, PVImpactGreenButton::AggregationType::ONE_DAY)

      expect(aggregated_usage_point.subscription_id).to eq('test')
      expect(aggregated_usage_point.kind).to eq('electricity')
      expect(aggregated_usage_point.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(aggregated_usage_point.local_time_parameters).not_to eq(nil)
      expect(aggregated_usage_point.electricity_power_usage_summaries).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.length).to eq(1)
      expect(aggregated_usage_point.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks.length).to eq(15)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..14).each do |i|
        expect(aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(expected_interval_reading_counts[i])
        aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on aggregate with DEFAULT aggregation_type
  describe 'aggregate with DEFAULT' do
    it 'should be successful' do
      aggregated_usage_point = PVImpactGreenButton::Aggregator.aggregate(@usage_points.first, PVImpactGreenButton::AggregationType::DEFAULT)

      expect(aggregated_usage_point.subscription_id).to eq('test')
      expect(aggregated_usage_point.kind).to eq('electricity')
      expect(aggregated_usage_point.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(aggregated_usage_point.local_time_parameters).not_to eq(nil)
      expect(aggregated_usage_point.electricity_power_usage_summaries).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.length).to eq(1)
      expect(aggregated_usage_point.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks.length).to eq(15)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..14).each do |i|
        expect(aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(expected_interval_reading_counts[i])
        aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end

    end
  end

  # Test on aggregate with ONE_DAY aggregation_type
  describe 'aggregate with ONE_DAY aggregation_type' do
    it 'should be successful' do
      aggregated_usage_point = PVImpactGreenButton::Aggregator.aggregate(@usage_points.first, PVImpactGreenButton::AggregationType::DEFAULT)

      expect(aggregated_usage_point.subscription_id).to eq('test')
      expect(aggregated_usage_point.kind).to eq('electricity')
      expect(aggregated_usage_point.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(aggregated_usage_point.local_time_parameters).not_to eq(nil)
      expect(aggregated_usage_point.electricity_power_usage_summaries).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.length).to eq(1)
      expect(aggregated_usage_point.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks.length).to eq(15)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..14).each do |i|
        expect(aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(expected_interval_reading_counts[i])
        aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end

    end
  end

  # Test on aggregate with ONE_MONTH aggregation_type
  describe 'aggregate with ONE_MONTH aggregation_type' do
    it 'should be successful' do
      aggregated_usage_point = PVImpactGreenButton::Aggregator.aggregate(@usage_points.first, PVImpactGreenButton::AggregationType::ONE_MONTH)

      expect(aggregated_usage_point.subscription_id).to eq('test')
      expect(aggregated_usage_point.kind).to eq('electricity')
      expect(aggregated_usage_point.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(aggregated_usage_point.local_time_parameters).not_to eq(nil)
      expect(aggregated_usage_point.electricity_power_usage_summaries).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.length).to eq(1)
      expect(aggregated_usage_point.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks.length).to eq(15)

      (0..14).each do |i|
        expect(aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(1)
        aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on aggregate with FIFTEEN_MINUTES aggregation_type
  describe 'aggregate with FIFTEEN_MINUTES aggregation_type' do
    it 'should be successful' do
      aggregated_usage_point = PVImpactGreenButton::Aggregator.aggregate(@usage_points.first, PVImpactGreenButton::AggregationType::FIFTEEN_MINUTES)

      expect(aggregated_usage_point.subscription_id).to eq('test')
      expect(aggregated_usage_point.kind).to eq('electricity')
      expect(aggregated_usage_point.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(aggregated_usage_point.local_time_parameters).not_to eq(nil)
      expect(aggregated_usage_point.electricity_power_usage_summaries).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.length).to eq(1)
      expect(aggregated_usage_point.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks.length).to eq(15)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..14).each do |i|
        expect(aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(4 * 24 * expected_interval_reading_counts[i])
        aggregated_usage_point.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on aggregate with FIFTEEN_MINUTES aggregation_type for accuracy verification
  describe 'aggregate with FIFTEEN_MINUTES aggregation_type accuracy verification' do
    it 'should be successful' do
      @parser.parse('spec/fixtures/case_1_day_daily_interval.xml', 'test')
      usage_point = @parser.usage_points.first
      aggregated_usage_point = PVImpactGreenButton::Aggregator.aggregate(usage_point, PVImpactGreenButton::AggregationType::FIFTEEN_MINUTES)

      expect(aggregated_usage_point.subscription_id).to eq('test')
      expect(aggregated_usage_point.kind).to eq('electricity')
      expect(aggregated_usage_point.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/RetailCustomer/1/UsagePoint/1')
      expect(aggregated_usage_point.local_time_parameters).not_to eq(nil)
      expect(aggregated_usage_point.electricity_power_usage_summaries).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.length).to eq(1)
      expect(aggregated_usage_point.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(aggregated_usage_point.meter_readings.first.interval_blocks.length).to eq(1)

      expect(aggregated_usage_point.meter_readings.first.interval_blocks[0].interval_readings.length).to eq(4 * 24)
      expected_costs = [646.25, 646.25, 646.25, 646.25, 184.5, 184.5, 184.5, 184.5, 213.5, 213.5,
                        213.5, 213.5, 211.25, 211.25, 211.25, 211.25, 197.0, 197.0, 197.0, 197.0,
                        217.75, 217.75, 217.75, 217.75, 566.0, 566.0, 566.0, 566.0, 1953.5, 1953.5,
                        1953.5, 1953.5, 2005.75, 2005.75, 2005.75, 2005.75, 1890.5, 1890.5, 1890.5,
                        1890.5, 2189.25, 2189.25, 2189.25, 2189.25, 2022.25, 2022.25, 2022.25,
                        2022.25, 1844.25, 1844.25, 1844.25, 1844.25, 1932.75, 1932.75, 1932.75, 1932.75,
                        1851.75, 1851.75, 1851.75, 1851.75, 3195.5, 3195.5, 3195.5, 3195.5, 3760.50,
                        3760.50, 3760.50, 3760.50, 5190.25, 5190.25, 5190.25, 5190.25, 5001.25, 5001.25,
                        5001.25, 5001.25, 5247.0, 5247.0, 5247.0, 5247.0, 8246.25, 8246.25, 8246.25, 8246.25,
                        6582.25, 6582.25, 6582.25, 6582.25, 4440.5, 4440.5, 4440.5, 4440.5, 1121.25, 1121.25, 1121.25, 1121.25]

      expected_values = [215.25, 215.25, 215.25, 215.25, 61.5, 61.5, 61.5,
                         61.5, 71.0, 71.0, 71.0, 71.0, 70.25, 70.25, 70.25, 70.25, 65.5, 65.5, 65.5,
                         65.5, 72.5, 72.5, 72.5, 72.5, 188.5, 188.5, 188.5, 188.5, 325.5, 325.5, 325.5, 325.5,
                         334.25, 334.25, 334.25, 334.25, 315.0, 315.0, 315.0, 315.0, 364.75, 364.75, 364.75, 364.75,
                         337.0, 337.0, 337.0, 337.0, 307.25, 307.25, 307.25, 307.25, 322.0, 322.0, 322.0, 322.0, 308.5,
                         308.5, 308.5, 308.5, 355.0, 355.0, 355.0, 355.0, 313.25, 313.25, 313.25, 313.25, 346.0, 346.0,
                         346.0, 346.0, 333.25, 333.25, 333.25, 333.25, 349.75, 349.75, 349.75, 349.75, 343.5, 343.5,
                         343.5, 343.5, 365.5, 365.5, 365.5, 365.5, 370.0, 370.0, 370.0, 370.0, 186.75, 186.75, 186.75, 186.75]

      (0..23).each do |i|
        interval_reading = aggregated_usage_point.meter_readings.first.interval_blocks[0].interval_readings[i]
        expect(interval_reading.value).not_to eq(nil)
        expect(interval_reading.cost).not_to eq(nil)
        expect(interval_reading.value).to be_within(0.01).of(expected_values[i])
        expect(interval_reading.cost).to be_within(0.01).of(expected_costs[i])
      end
    end
  end
end