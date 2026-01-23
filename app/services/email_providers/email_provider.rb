module EmailProviders
  class EmailProvider
    def send_email(to:, subject:, html_body:, text_body: nil, from: nil, metadata: {})
      raise NotImplementedError, "Implement in provider adapter"
    end

    private
      def default_from
        Rails.application.config.email_default_from
      end
  end
end
