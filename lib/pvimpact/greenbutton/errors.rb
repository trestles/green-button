# Copyright (c) 2015, TopCoder Inc., All Rights Reserved.
# Author: albertwang
# Version: 1.0

module PVImpactGreenButton
  # Public: This is the base class for errors raised in this gem.
  class GreenButtonError < StandardError; end

  # Public: This error indicates unsupported service kind.
  class UnsupportedServiceKindError < GreenButtonError; end

  # Public: This error indicates error during parsing GreenButton data.
  class ParsingError < GreenButtonError; end

  # Public: This error indicates error during accessing persistence.
  class PersistenceError < GreenButtonError; end

  # Public: This error indicates error during aggregating data.
  class AggregationError < GreenButtonError; end
end
