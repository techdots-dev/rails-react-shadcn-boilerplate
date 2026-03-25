module PaymentProviders
  class Error < StandardError
    attr_reader :status, :details, :response_body

    def initialize(message, status: nil, details: nil, response_body: nil)
      super(message)
      @status = status
      @details = details
      @response_body = response_body
    end
  end
end
