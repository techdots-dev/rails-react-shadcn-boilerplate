module Payments
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      super("Validation failed")
      @errors = errors
    end
  end
end
