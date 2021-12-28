# frozen_string_literal: true

#= IdentityToken
#
# The tokens we obtain when authenticating users through Google Cloud Identity
# Platform
class IdentityToken
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  # Transient attributes:
  attr_accessor :token, :payload, :header, :decoding_errors
  attr_reader :issuer, :subject, :audience, :issued_at, :expires_at,
              :authenticated_at, :created_at

  before_validation :extract_token_payload

  def find_or_create_subject
    return unless valid?

    users_matching_payload_identity.first || create_user_from_payload
  end

  def self.load(token)
    new(token: token)
  end

  private

  def extract_token_payload
    @payload, @header, @decoding_errors = DecodeIdentityToken.perform!(token)
    return if payload.blank?

    extract_string_attributes_from_payload
    extract_timestamp_attributes_from_payload
  end

  def create_user_from_payload
    User.create payload
      .slice('email', 'name')
      .merge(identity_platform_id: payload['sub'])
  end

  def users_matching_payload_identity
    return unless payload

    User
      .where(identity_platform_id: payload['sub'])
      .or(User.where(email: payload['email']))
  end

  def extract_string_attributes_from_payload
    @issuer   = payload['iss']
    @subject  = payload['sub']
    @audience = payload['aud']
  end

  def extract_timestamp_attributes_from_payload
    @issued_at        = Time.at(payload['iat'])
    @expires_at       = Time.at(payload['exp'])
    @authenticated_at = Time.at(payload['auth_time'])
  end
end
