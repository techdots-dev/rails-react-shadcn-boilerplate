require "json"
require "net/http"
require "uri"

module PaymentProviders
  class PaysimpleClient
    API_VERSION = "v4".freeze

    def initialize(username:, api_key:, base_url:, http: Net::HTTP)
      @username = username
      @api_key = api_key
      @base_url = base_url
      @http = http
    end

    def get(path)
      request(:get, path)
    end

    def post(path, payload)
      request(:post, path, payload)
    end

    def delete(path)
      request(:delete, path)
    end

    private
      def request(method, path, payload = nil)
        ensure_credentials!

        uri = build_uri(path)
        http_request = request_class(method).new(uri)
        http_request["Accept"] = "application/json"
        http_request["Authorization"] = "basic #{@username}:#{@api_key}"

        if payload
          http_request["Content-Type"] = "application/json"
          http_request.body = JSON.generate(payload)
        end

        response = @http.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |connection|
          connection.request(http_request)
        end

        parse_response(response)
      rescue JSON::ParserError
        raise Error.new("PaySimple returned an invalid JSON response")
      rescue IOError, SocketError, SystemCallError, Timeout::Error => error
        raise Error.new("PaySimple request failed: #{error.message}")
      end

      def build_uri(path)
        normalized_path = path.to_s.start_with?("/") ? path.to_s : "/#{path}"
        base_uri = URI.parse(@base_url)
        base_prefix = base_uri.path.to_s.sub(%r{/+\z}, "").sub(%r{/#{API_VERSION}\z}, "")
        base_uri.path = [ base_prefix, API_VERSION, normalized_path.delete_prefix("/") ]
          .reject(&:blank?)
          .map { |segment| segment.delete_prefix("/") }
          .join("/")
          .prepend("/")
        base_uri.query = nil
        base_uri
      end

      def ensure_credentials!
        return if @username.present? && @api_key.present?

        raise Error.new("PaySimple credentials are not configured")
      end

      def parse_response(response)
        parsed_body = response.body.present? ? JSON.parse(response.body) : {}
        body = unwrap_response(parsed_body)
        return body if response.code.to_i.between?(200, 299)

        details = extract_error_details(parsed_body)
        raise Error.new(
          extract_error_message(details, parsed_body, response.code.to_i),
          status: response.code.to_i,
          details: details,
          response_body: body
        )
      end

      def unwrap_response(parsed_body)
        return parsed_body["Response"] if parsed_body.is_a?(Hash) && parsed_body.key?("Response")

        parsed_body
      end

      def extract_error_details(parsed_body)
        return parsed_body.dig("Meta", "Errors") if parsed_body.is_a?(Hash) && parsed_body.dig("Meta", "Errors").present?
        return parsed_body["Errors"] if parsed_body.is_a?(Hash) && parsed_body["Errors"].present?

        parsed_body
      end

      def extract_error_message(details, parsed_body, status)
        return details.first["Message"] if details.is_a?(Array) && details.first.is_a?(Hash) && details.first["Message"].present?
        return details["Message"] if details.is_a?(Hash) && details["Message"].present?
        return parsed_body["Message"] if parsed_body.is_a?(Hash) && parsed_body["Message"].present?

        "PaySimple request failed with status #{status}"
      end

      def request_class(method)
        {
          get: Net::HTTP::Get,
          post: Net::HTTP::Post,
          delete: Net::HTTP::Delete
        }.fetch(method)
      end
  end
end
