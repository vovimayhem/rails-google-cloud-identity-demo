# frozen_string_literal: true

class DecodeIdentityToken
  #= DecodeIdentityToken::CertStore
  #
  # This class is used by the DecodeIdentityToken service to retrieve and store
  # the certificates used to properly decode tokens issued by Google Cloud
  # Identity Platform
  class CertStore
    extend MonitorMixin

    CERTS_URI = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
    CERTS_EXPIRY = 3600

    class FetchError < StandardError; end

    class << self
      attr_reader :certs_last_refresh

      def certs_cache_expired?
        return true unless certs_last_refresh

        Time.now > certs_last_refresh + CERTS_EXPIRY
      end

      def certs
        refresh_certs if certs_cache_expired?
        @certs
      end

      def connection
        # decode response bodies as JSON
        @connection ||= Faraday.new { |f| f.response :json }
      end

      def fetch_certs
        response = connection.get CERTS_URI
        return response if response.success?

        raise FetchError, 'Failed to fetch token certificates from Google'
      end

      def refresh_certs
        synchronize do
          return unless (response = fetch_certs)

          new_certs = response.body.transform_values do |cert|
            OpenSSL::X509::Certificate.new(cert)
          end

          (@certs ||= {}).merge! new_certs
          @certs_last_refresh = Time.now
        end
      end
    end
  end
end
