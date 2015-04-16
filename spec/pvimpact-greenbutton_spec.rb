# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

require 'spec_helper'

# Tests on main module PVImpactGreenButton.
describe PVImpactGreenButton do
  # This is the test URL.
  TEST_URL = 'https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Batch/Subscription/5'

  # This is the test access token.
  TEST_TOKEN = '688b026c-665f-4994-9139-6b21b13fbeee'

  # Clean up database.
  # after do
  #   PVImpactGreenButton::UsagePoint.all.destroy
  # end

  # Test on download_data with nil access_token
  describe 'download_data with nil access_token' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(nil, TEST_URL) }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with empty access_token
  describe 'download_data with empty access_token' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(' ', TEST_URL) }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with nil resource_uri
  describe 'download_data with nil resource_uri' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(TEST_TOKEN, nil) }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with empty resource_uri
  describe 'download_data with empty resource_uri' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(TEST_TOKEN, ' ') }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with invalid interval_start_time
  describe 'download_data with invalid interval_start_time' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, 122) }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with invalid interval_end_time
  describe 'download_data with invalid interval_end_time' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, Time.new(2012, 1, 1), 111) }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with invalid date range
  describe 'download_data with invalid date range' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, Time.new(2012, 1, 1), Time.new(2011, 12, 31)) }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with invalid aggregation_type
  describe 'download_data with invalid aggregation_type' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, Time.new(2012, 1, 1), Time.new(2012, 1, 2), 'abc') }.to raise_error(ArgumentError)
    end
  end

  # Test on download_data with invalid resource_uri
  describe 'download_data with invalid resource_uri' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data(TEST_TOKEN, 'http://not_exist') }.to raise_error(PVImpactGreenButton::GreenButtonError)
    end
  end

  # Test on download_data with invalid access_token
  describe 'download_data with invalid access_token' do
    it 'should fail' do
      expect { PVImpactGreenButton.download_data('invalid', TEST_URL) }.to raise_error(PVImpactGreenButton::GreenButtonError)
    end
  end

  # Test on download_data without aggregation
  describe 'download_data without aggregation' do
    it 'should succeed' do
      usage_points = PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)
      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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

  # Test on download_data with nil aggregation
  describe 'download_data with nil aggregation' do
    it 'should succeed' do
      usage_points = PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, nil, nil, nil)
      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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

  # Test on download_data with ONE_DAY aggregation
  describe 'download_data with ONE_DAY aggregation' do
    it 'should succeed' do
      usage_points = PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::ONE_DAY)
      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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

  # Test on download_data with DEFAULT aggregation
  describe 'download_data with DEFAULT aggregation' do
    it 'should succeed' do
      usage_points = PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::DEFAULT)
      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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

  # Test on download_data with date range
  describe 'download_data with date range' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::DEFAULT)
      usage_points = PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, Time.new(2013, 1, 1, 0, 0, 0, '+00:00'), Time.new(2013, 3, 1, 0, 0, 0, '+00:00'))
      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(1)

      expect(usage_points.first.meter_readings.first.interval_blocks.first.interval_readings.length).to eq(31)
      usage_points.first.meter_readings.first.interval_blocks.first.interval_readings.each do |interval_reading|
        expect(interval_reading.value).not_to eq(nil)
        expect(interval_reading.cost).not_to eq(nil)
        expect(interval_reading.value).to be > 0
        expect(interval_reading.cost).to be > 0
      end
    end
  end

  # Test on download_data with ONE_MONTH aggregation
  describe 'download_data with ONE_MONTH aggregation' do
    it 'should succeed' do
      usage_points = PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::ONE_MONTH)
      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(15)

      (0..14).each do |i|
        expect(usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(1)
        usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on download_data with FIFTEEN_MINUTES aggregation
  # NOTE this may take long time to complete because there will be quite a lot interval readings to insert into DB
  describe 'download_data with FIFTEEN_MINUTES aggregation' do
    it 'should succeed' do
      usage_points = PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::FIFTEEN_MINUTES)
      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)

      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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
        expect(usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(4 * 24 * expected_interval_reading_counts[i])
        usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on retrieve_data with nil subscription_id
  describe 'retrieve_data with nil subscription_id' do
    it 'should fail' do
      expect { PVImpactGreenButton.retrieve_data(nil) }.to raise_error(ArgumentError)
    end
  end

  # Test on retrieve_data with empty subscription_id
  describe 'retrieve_data with empty subscription_id' do
    it 'should fail' do
      expect { PVImpactGreenButton.retrieve_data(' ') }.to raise_error(ArgumentError)
    end
  end

  # Test on retrieve_data with invalid interval_start_time
  describe 'retrieve_data with invalid interval_start_time' do
    it 'should fail' do
      expect { PVImpactGreenButton.retrieve_data(TEST_URL, 122) }.to raise_error(ArgumentError)
    end
  end

  # Test on retrieve_data with invalid interval_end_time
  describe 'retrieve_data with invalid interval_end_time' do
    it 'should fail' do
      expect { PVImpactGreenButton.retrieve_data(TEST_URL, Time.new(2012, 1, 1), 111) }.to raise_error(ArgumentError)
    end
  end

  # Test on retrieve_data with invalid date range
  describe 'retrieve_data with invalid date range' do
    it 'should fail' do
      expect { PVImpactGreenButton.retrieve_data(TEST_URL, Time.new(2012, 1, 1), Time.new(2011, 12, 31)) }.to raise_error(ArgumentError)
    end
  end

  # Test on retrieve_data with invalid aggregation_type
  describe 'retrieve_data with invalid aggregation_type' do
    it 'should fail' do
      expect { PVImpactGreenButton.retrieve_data(TEST_URL, Time.new(2012, 1, 1), Time.new(2012, 1, 2), 'abc') }.to raise_error(ArgumentError)
    end
  end

  # Test on retrieve_data without aggregation
  describe 'retrieve_data without aggregation' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL)

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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

  # Test on retrieve_data with nil aggregation
  describe 'retrieve_data with nil aggregation' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL, nil, nil, nil)

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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

  # Test on retrieve_data with ONE_DAY aggregation
  describe 'retrieve_data with ONE_DAY aggregation' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::ONE_DAY)

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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

  # Test on retrieve_data with ONE_MONTH aggregation
  describe 'retrieve_data with ONE_MONTH aggregation' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::ONE_MONTH)

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(15)

      (0..14).each do |i|
        expect(usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(1)
        usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on retrieve_data with FIFTEEN_MINUTES aggregation
  describe 'retrieve_data with FIFTEEN_MINUTES aggregation' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL, nil, nil, PVImpactGreenButton::AggregationType::FIFTEEN_MINUTES)

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)

      expect(usage_points.first.subscription_id).to eq(TEST_URL)
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
        expect(usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.length).to eq(4 * 24 * expected_interval_reading_counts[i])
        usage_points.first.meter_readings.first.interval_blocks[i].interval_readings.each do |interval_reading|
          expect(interval_reading.value).not_to eq(nil)
          expect(interval_reading.cost).not_to eq(nil)
          expect(interval_reading.value).to be > 0
          expect(interval_reading.cost).to be > 0
        end
      end
    end
  end

  # Test on retrieve_data with interval_start_time
  describe 'retrieve_data with interval_start_time' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL, Time.new(2013, 3, 1))

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(13)

      expected_interval_reading_counts = [31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28, 20]
      (0..12).each do |i|
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

  # Test on retrieve_data with interval_end_time
  describe 'retrieve_data with interval_end_time' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL, nil, Time.new(2014, 2, 2))

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(13)

      expected_interval_reading_counts = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31]
      (0..12).each do |i|
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

  # Test on retrieve_data with date range
  describe 'retrieve_data with date range' do
    it 'should succeed' do
      PVImpactGreenButton.download_data(TEST_TOKEN, TEST_URL)

      usage_points = PVImpactGreenButton.retrieve_data(TEST_URL, Time.new(2013, 3, 1), Time.new(2013, 5, 2))

      expect(usage_points).not_to eq(nil)
      expect(usage_points.length).to eq(1)
      expect(usage_points.first.subscription_id).to eq(TEST_URL)
      expect(usage_points.first.kind).to eq('electricity')
      expect(usage_points.first.id).to eq('https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Subscription/5/UsagePoint/1')
      expect(usage_points.first.local_time_parameters).not_to eq(nil)
      expect(usage_points.first.electricity_power_usage_summaries).not_to eq(nil)
      expect(usage_points.first.meter_readings).not_to eq(nil)
      expect(usage_points.first.meter_readings.length).to eq(1)
      expect(usage_points.first.meter_readings.first.meter_reading_type).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks).not_to eq(nil)
      expect(usage_points.first.meter_readings.first.interval_blocks.length).to eq(2)

      expected_interval_reading_counts = [31, 30]
      (0..1).each do |i|
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
end