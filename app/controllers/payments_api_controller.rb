class PaymentsApiController < ApiController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Payments::ValidationError, with: :render_validation_error
  rescue_from PaymentProviders::Error, with: :render_provider_error

  private
    def render_not_found(error)
      render json: { error: error.message }, status: :not_found
    end

    def render_validation_error(error)
      render json: { errors: error.errors }, status: :unprocessable_content
    end

    def render_provider_error(error)
      status = [ 400, 404, 422 ].include?(error.status.to_i) ? error.status : :bad_gateway
      render json: { error: error.message, details: error.details }.compact, status:
    end
end
