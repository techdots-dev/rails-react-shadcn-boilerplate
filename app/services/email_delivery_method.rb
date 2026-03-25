require "json"

class EmailDeliveryMethod
  def initialize(options = {})
    @provider_name = options.fetch(:provider, Rails.application.config.email_provider)
  end

  def deliver!(mail)
    provider = EmailProviders::Registry.build(name: @provider_name)

    provider.send_email(
      to: mail.to,
      subject: mail.subject,
      html_body: html_body_for(mail),
      text_body: text_body_for(mail),
      from: mail.from&.first,
      metadata: metadata_for(mail)
    )
  end

  private
    def html_body_for(mail)
      return mail.html_part.body.decoded if mail.html_part
      return mail.body.decoded if mail.content_type&.include?("html")

      nil
    end

    def text_body_for(mail)
      return mail.text_part.body.decoded if mail.text_part
      return mail.body.decoded if mail.content_type&.include?("text/plain")

      nil
    end

    def metadata_for(mail)
      header = mail["X-Metadata"]
      return {} unless header

      JSON.parse(header.value)
    rescue JSON::ParserError
      {}
    end
end
