class PaymentsController < PaymentsApiController
  before_action :set_payment, only: :show

  def index
    render json: Current.user.payments.newest_first.map(&:as_api_json)
  end

  def show
    render json: @payment.as_api_json
  end

  def create
    payment = Payments::PaymentCreator.new.call(
      user: Current.user,
      attributes: payment_params.to_h.deep_symbolize_keys
    )

    render json: payment.as_api_json, status: :created
  end

  private
    def set_payment
      @payment = Current.user.payments.find(params[:id])
    end

    def payment_params
      params.permit(:payment_method_id, :amount, :description, :order_id, :invoice_number)
    end
end
