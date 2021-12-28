# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/contexts/example_identity_token'

RSpec.describe IdentityToken, type: :model do
  include_context 'example identity token'

  let(:example_user_name) { 'Example name' }
  let(:example_user_email) { 'example-account@example.com' }
  let(:example_user_identity_platform_id) { 'example-user-identity-platform-id' }

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

  subject { described_class.load example_token }

  before do
    allow(DecodeIdentityToken).to receive(:perform!)
      .with(example_token)
      .and_return([example_token_payload])

    allow(IdentityToken::Validator).to receive(:expected_audience)
      .and_return example_audience
  end

  describe '.load' do
    it 'initializes an instance with the given token' do
      expect(described_class.load(example_token)).to have_attributes token: example_token
    end
  end

  it 'extracts attributes from the given token before validations' do
    subject.valid?
    expect(subject).to have_attributes(
      issuer: example_token_issuer,
      subject: example_user_identity_platform_id,
      audience: example_audience,
      issued_at: example_token_issue_time,
      expires_at: example_token_expiration_time,
      authenticated_at: example_authentication_time
    )
  end

  describe '#find_or_create_subject' do
    context 'for a new user' do
      it 'creates a new user' do
        created_user = nil
        expect { created_user = subject.find_or_create_subject }
          .to change(User, :count).by 1

        expect(created_user).to be_persisted
        expect(created_user).to have_attributes(
          name: example_user_name,
          email: example_user_email,
          identity_platform_id: example_user_identity_platform_id
        )
      end
    end

    context 'from an existing user' do
      let(:example_user) { create :user }
      let(:example_user_name) { example_user.name }
      let(:example_user_email) { example_user.email }
      let(:example_user_identity_platform_id) { example_user.identity_platform_id }

      it 'associates the token with the existing user' do
        found_user = nil
        expect { found_user = subject.find_or_create_subject }
          .not_to change(User, :count)

        expect(found_user).to be_persisted
        expect(found_user).to eq example_user
      end
    end
  end
end
