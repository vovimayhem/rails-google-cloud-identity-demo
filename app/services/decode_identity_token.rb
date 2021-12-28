# frozen_string_literal: true

#= DecodeIdentityToken
#
# This service class is used to properly decode an identity token issued by
# Google Cloud Identity Platform
class DecodeIdentityToken
  include Performable

  attr_reader :token, :payload, :header, :decoding_errors

  def initialize(token)
    @token = token

    @decoding_errors = []
    @payload, @header = @decoding_errors
  end

  def perform!
    return output_for_perform if already_performed?

    decode_token_with_certs
    output_for_perform
  end

  def self.decode_token_with_cert(token, key, cert)
    public_key = cert.public_key

    JWT.decode(
      token,
      public_key,
      !public_key.nil?,
      { algorithm: 'RS256', kid: key }
    )
  end

  delegate :certs, to: CertStore
  delegate :decode_token_with_cert, to: :class

  private

  def already_performed?
    payload || decoding_errors.present?
  end

  def output_for_perform
    [payload, header, decoding_errors]
  end

  def decode_token_with_certs
    certs.detect do |key, cert|
      break unless assign_payload_and_header_with_key_and_cert(key, cert)
    rescue JWT::ExpiredSignature
      @decoding_errors << 'signature expired'
      break
    rescue JWT::DecodeError
      nil # go on, try the next cert
    end
  end

  def assign_payload_and_header_with_key_and_cert(key, cert)
    return if payload.present?

    @payload, @header = decode_token_with_cert(token, key, cert)
  end
end
