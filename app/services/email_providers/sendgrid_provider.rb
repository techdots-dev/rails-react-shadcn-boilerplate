require "net/http"
require "json"

module EmailProviders
  class SendgridProvider < EmailProvider
    SENDGRID_ENDPOINT = "https://api.sendgrid.com/v3/mail/send".freeze

    def initialize(api_key:)
      @api_key = api_key
    end

    def send_email(to:, subject:, html_body:, text_body: nil, from: nil, metadata: {})
      ensure_api_key!

      payload = {
        personalizations: [
          {
            to: Array(to).map { |email| { email: email } },
            subject: subject,
            custom_args: metadata
          }
        ],
        from: { email: from || default_from },
        content: build_content(html_body, text_body)
      }

      response = http_post(SENDGRID_ENDPOINT, payload)
      handle_response(response)
    end

    private
      def ensure_api_key!
        return if @api_key.present?

        raise ArgumentError, "SendGrid API key is required"
      end

      def build_content(html_body, text_body)
        content = []
        content << { type: "text/plain", value: text_body } if text_body.present?
        content << { type: "text/html", value: html_body } if html_body.present?
        content
      end

      def http_post(url, payload)
        uri = URI.parse(url)
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request.body = payload.to_json

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end
      end

      def handle_response(response)
        return response if response.code.to_i.between?(200, 299)

        raise StandardError, "SendGrid error (status #{response.code}): #{response.body}"
      end
  end
end
