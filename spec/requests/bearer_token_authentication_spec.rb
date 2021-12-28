# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/contexts/example_identity_token'

RSpec.describe 'Bearer Token Authentication', type: :request do
  include_context 'example identity token'

  let :example_authorization_headers do
    { 'Authorization' => "Bearer #{example_token}" }
  end

  before do
    allow(DecodeIdentityToken).to receive(:perform!)
      .with(example_token)
      .and_return([example_token_payload])

    allow(IdentityToken::Validator).to receive(:expected_audience)
      .and_return example_audience
  end

  describe 'GET /' do
    it 'returns http success with the bearer token header' do
      get '/', headers: example_authorization_headers
      expect(response).to have_http_status(:success)
    end

    it 'renders content intended for authenticated users' do
      get '/', headers: example_authorization_headers
      expect(response.body).to include 'Home#show'
    end
  end
end
