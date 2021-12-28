# frozen_string_literal: true

Warden::Strategies.add(:identity_token) do
  def valid?
    !token_string.nil?
  end

  def authenticate!
    fail! 'invalid_token' and return unless token&.valid?

    success! token.find_or_create_subject
  end

  def store?
    false
  end

  private

  def token
    @token ||= IdentityToken.load(token_string) if valid?
  end

  def token_string
    token_string_from_header || token_string_from_request_params
  end

  def token_string_from_header
    Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |key|
      if env.key?(key) && (token_string = env[key][/^Bearer (.*)/, 1])
        return token_string
      end
    end
    nil
  end

  def token_string_from_request_params
    params['access_token']
  end
end

Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :identity_token
  manager.failure_app = UnauthorizedController

  manager.serialize_into_session(&:id)
  manager.serialize_from_session { |id| User.find_by id: id }
end
