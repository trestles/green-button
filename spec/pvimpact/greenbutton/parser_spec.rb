# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0
require 'spec_helper'

# Tests on Parser.
describe PVImpactGreenButton::Parser do
  # Create parser before running test case.
  before do
    @parser = PVImpactGreenButton::Parser.new()
  end

  # Tests on parse to parse XML with 15 months daily interval data
  describe "parse - '15 months daily interval'" do
    it 'should be successful' do
      @parser.parse('spec/fixtures/case_15_months_daily_interval.xml', 'test')
      usage_points = @parser.usage_points

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq('test')
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(15)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..14).each do |i|
        expect(usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(expected_interval_reading_counts[i])
        usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Tests on parse to parse XML with 12 months daily interval data
  describe "parse - '12 months daily interval'" do
    it 'should be successful' do
      @parser.parse('spec/fixtures/case_12_months_daily_interval.xml', 'test')
      usage_points = @parser.usage_points

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq('test')
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(12)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      (0..11).each do |i|
        expect(usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(expected_interval_reading_counts[i])
        usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Tests on parse to parse XML with 1 month daily interval data
  describe "parse - '1 month daily interval'" do
    it 'should be successful' do
      @parser.parse('spec/fixtures/case_1_month_daily_interval.xml', 'test')
      usage_points = @parser.usage_points

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq('test')
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/RetailCustomer/1/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(30)

      # expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..29).each do |i|
        expect(usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(24)
        usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Tests on parse to parse XML without usage points data
  describe "parse - 'without usage points'" do
    it 'should be successful' do
      @parser.parse('spec/fixtures/case_without_usage_point.xml', 'test')
      expect(@parser.interval_blocks.length).to eq(1)
      expect(@parser.usage_points.empty?).to eq(true)
    end
  end

  # Tests on parse with nil path
  describe "parse - nil path" do
    it 'should fail' do
      expect{ @parser.parse(nil, 'test') }.to raise_error(ArgumentError)
    end
  end

  # Tests on parse with blank path
  describe "parse - blank path" do
    it 'should fail' do
      expect{ @parser.parse(' ', 'test') }.to raise_error(ArgumentError)
    end
  end

  # Tests on parse with nil subscription_id
  describe "parse - nil subscription_id" do
    it 'should fail' do
      expect{ @parser.parse('spec/fixtures/case_without_usage_point.xml', nil) }.to raise_error(ArgumentError)
    end
  end

  # Tests on parse with blank subscription_id
  describe "parse - blank subscription_id" do
    it 'should fail' do
      expect{ @parser.parse('spec/fixtures/case_without_usage_point.xml', '') }.to raise_error(ArgumentError)
    end
  end
end