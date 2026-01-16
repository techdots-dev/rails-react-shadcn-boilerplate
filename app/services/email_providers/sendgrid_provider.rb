require "sendgrid-ruby"

module EmailProviders
  class SendgridProvider < EmailProvider
    def initialize(api_key:)
      @api_key = api_key
    end

    def send_email(to:, subject:, html_body:, text_body: nil, from: nil, metadata: {})
      ensure_api_key!

      payload = build_payload(
        to: to,
        subject: subject,
        html_body: html_body,
        text_body: text_body,
        from: from,
        metadata: metadata
      )

      response = client.client.mail._("send").post(request_body: payload)
      handle_response(response)
    end

    private
      def ensure_api_key!
        return if @api_key.present?

        raise ArgumentError, "SendGrid API key is required"
      end

      def client
        @client ||= SendGrid::API.new(api_key: @api_key)
      end

      def build_payload(to:, subject:, html_body:, text_body:, from:, metadata:)
        {
          personalizations: [
            {
              to: Array(to).map { |email| { email: email } },
              subject: subject,
              custom_args: metadata.presence
            }.compact
          ],
          from: { email: from || default_from },
          content: build_content(html_body, text_body)
        }
      end

      def build_content(html_body, text_body)
        content = []
        content << { type: "text/plain", value: text_body } if text_body.present?
        content << { type: "text/html", value: html_body } if html_body.present?
        content
      end

      def handle_response(response)
        return response if response.status_code.to_i.between?(200, 299)

        raise StandardError, "SendGrid error (status #{response.status_code}): #{response.body}"
      end
  end
end
