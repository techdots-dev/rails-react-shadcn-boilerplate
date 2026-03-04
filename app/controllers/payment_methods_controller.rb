class PaymentMethodsController < PaymentsApiController
  before_action :set_payment_method, only: :show

  def index
    render json: Current.user.payment_methods.newest_first.map(&:as_api_json)
  end

  def show
    render json: @payment_method.as_api_json
  end

  def create
    payment_method = Payments::PaymentMethodCreator.new.call(
      user: Current.user,
      attributes: payment_method_params.to_h.deep_symbolize_keys
    )

    render json: payment_method.as_api_json, status: :created
  end

  private
    def set_payment_method
      @payment_method = Current.user.payment_methods.find(params[:id])
    end

    def payment_method_params
      params.permit(
        :kind,
        :first_name,
        :last_name,
        :email,
        :phone,
        :company,
        :label,
        :default,
        :card_number,
        :expiration_month,
        :expiration_year,
        :cvv,
        :billing_zip,
        :account_number,
        :routing_number,
        :account_holder_name,
        :account_type,
        :bank_name,
        billing_address: %i[ street_address1 street_address2 city state postal_code country ]
      )
    end
end
