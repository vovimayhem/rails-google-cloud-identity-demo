# frozen_string_literal: true

RSpec.shared_context 'fetching certs from google' do
  let(:example_cert_service_response_body) { file_fixture('google-cert-server-response.json').read }
  let(:example_cert_service_response_data) { JSON.parse(example_cert_service_response_body) }

  before do
    stub_request(:get, DecodeIdentityToken::CertStore::CERTS_URI).to_return(
      status: 200, body: example_cert_service_response_body, headers: {
        'Content-Type' => 'application/json; charset=UTF-8'
      }
    )
  end
end
