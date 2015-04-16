# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

module PVImpactGreenButton
  # Public: This mixin provides utility methods to validate arguments.
  module Validation
    # Public: Validate a required argument.
    # arg - the argument
    # arg_name - the argument name
    # Raises ArgumentError if the argument is nil
    def validate_required(arg, arg_name)
      raise ArgumentError, "Argument #{arg_name} should not be nil." unless arg
    end

    # Public: Validate a string argument.
    # arg - the argument
    # arg_name - the argument name
    # Raises ArgumentError if the argument is not a valid string (if required)
    def validate_string(arg, arg_name, required = true)
      return if !required && !arg
      validate_required(arg, arg_name)
      raise ArgumentError, "Argument #{arg_name} should be string." unless arg.respond_to?(:to_s) && !(/\S/ !~ arg.to_s)
    end

    # Public: Validate a Time argument.
    # arg - the argument
    # arg_name - the argument name
    # required - if the argument is required
    # Raises ArgumentError if the argument is not a valid Time (if required)
    def validate_time(arg, arg_name, required = true)
      return if !required && !arg
      validate_required(arg, arg_name)
      raise ArgumentError, "Argument #{arg_name} should be Time." unless arg.is_a? Time
    end

    # Public: Validate a Time range.
    # arg1 - the argument 1
    # arg1_name - the argument 1 name
    # arg2 - the argument 2
    # arg2_name - the argument 2 name
    # Raises ArgumentError if the time range is invalid
    def validate_time_range(arg1, arg1_name, arg2, arg2_name)
      raise ArgumentError, "Argument #{arg1_name} should not be later than #{arg2_name}." if arg1 && arg2 && arg1 > arg2
    end

    # Public: Validate aggregation type.
    # arg - the argument
    # arg_name - the argument name
    # Raises ArgumentError if the argument is not valid integer.
    def validate_aggregation_type(arg, arg_name)
      raise ArgumentError, "Argument #{arg_name} is invalid integer." unless arg.is_a? Integer
    end
  end
end