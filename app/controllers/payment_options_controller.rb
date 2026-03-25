class PaymentOptionsController < PaymentsApiController
  def show
    render json: {
      provider: Rails.application.config.payment_provider,
      options: PaymentProviders::Registry.build.payment_options
    }
  end
end
