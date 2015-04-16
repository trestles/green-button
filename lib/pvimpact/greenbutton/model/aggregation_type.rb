# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0
require 'ruby-enum'

module PVImpactGreenButton
  # Public: This enum represents aggregation type.
  class AggregationType
    include Ruby::Enum

    # Public: Aggregation type of interval returned from GreenButton API.
    define :DEFAULT, 0

    # Public: Aggregation type of '15 minutes'.
    define :FIFTEEN_MINUTES, 60 * 15

    # Public: Aggregation type of '1 hour'.
    define :ONE_HOUR, 60 * 60

    # Public: Aggregation type of '1 day'.
    define :ONE_DAY, 60 * 60 * 24

    # Public: Aggregation type of '1 month'.
    define :ONE_MONTH, 60 * 60 * 24 * 31
  end
end
