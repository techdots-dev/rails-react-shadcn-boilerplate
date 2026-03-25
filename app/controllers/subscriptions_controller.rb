class SubscriptionsController < PaymentsApiController
  before_action :set_subscription, only: :show

  def index
    render json: Current.user.payment_subscriptions.newest_first.map(&:as_api_json)
  end

  def show
    render json: @subscription.as_api_json
  end

  def create
    subscription = Payments::SubscriptionCreator.new.call(
      user: Current.user,
      attributes: subscription_params.to_h.deep_symbolize_keys
    )

    render json: subscription.as_api_json, status: :created
  end

  private
    def set_subscription
      @subscription = Current.user.payment_subscriptions.find(params[:id])
    end

    def subscription_params
      params.permit(
        :payment_method_id,
        :amount,
        :description,
        :order_id,
        :invoice_number,
        :start_date,
        :end_date,
        :execution_frequency_type,
        :execution_frequency_parameter
      )
    end
end
