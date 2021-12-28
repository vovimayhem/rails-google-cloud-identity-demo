# frozen_string_literal: true

RSpec.shared_context 'example identity token' do
  let(:example_authentication_time) { Time.now.round(0) }
  let(:example_token_issue_time) { Time.now.round(0) }
  let(:example_audience) { 'example-project' }
  let(:example_token_issuer) { "https://securetoken.google.com/#{example_audience}" }

  let(:example_user) { create :user, :with_email }
  let(:example_user_name) { example_user.name }
  let(:example_user_email) { example_user.email }
  let(:example_user_identity_platform_id) { example_user.identity_platform_id }

  let :example_token_expiration_time do
    Time.at(example_token_issue_time.to_i + 100_000)
  end

  let :example_token_payload do
    {
      'aud' => example_audience,
      'name' => example_user_name,
      'iss' => example_token_issuer,
      'email' => example_user_email,
      'iat' => example_token_issue_time.to_i,
      'sub' => example_user_identity_platform_id,
      'exp' => example_token_expiration_time.to_i,
      'user_id' => example_user_identity_platform_id,
      'auth_time' => example_authentication_time.to_i
    }
  end

  let(:example_token) { JWT.encode(example_token_payload, nil, 'none') }
end
