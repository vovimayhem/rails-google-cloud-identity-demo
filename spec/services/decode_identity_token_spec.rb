# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/contexts/fetching_certs_from_google'

RSpec.describe DecodeIdentityToken do
  include_context 'fetching certs from google'

  let(:example_token) { 'EXAMPLETOKEN' }

  let :example_decoded_header do
    {
      'alg' => 'RS256',
      'kid' => '350342b0255002ab75e0534c582ecc66cf0e17d2',
      'typ' => 'JWT'
    }
  end

  let :example_decoded_payload do
    {
      'iss' => 'https://securetoken.google.com/talent-hunt-323219',
      'aud' => 'talent-hunt-323219',
      'auth_time' => 1_633_577_409,
      'user_id' => 'XXxXXXxxXXXxxxXXXx9xxxxXXX99',
      'sub' => 'XXxXXXxxXXXxxxXXXx9xxxxXXX99',
      'iat' => 1_633_577_410,
      'exp' => 1_633_581_010,
      'email' => 'example-user@example.com',
      'email_verified' => false,
      'firebase' => {
        'identities' => { 'email' => %w[example-user@example.com] },
        'sign_in_provider' => 'password'
      }
    }
  end

  let :example_jwt_decode_params do
    [example_token, anything, anything, { algorithm: 'RS256', kid: anything }]
  end

  subject { described_class.new example_token }

  describe '#perform!' do
    context 'with a token having a valid signature' do
      before do
        allow(JWT).to receive(:decode)
          .with(*example_jwt_decode_params)
          .and_return [example_decoded_payload, example_decoded_header]
      end

      it 'returns the payload' do
        expect(subject.perform!.first).to eq example_decoded_payload
      end

      it 'returns the header' do
        expect(subject.perform!.second).to eq example_decoded_header
      end

      it 'returns an empty list of decoding errors' do
        expect(subject.perform!.last).to be_empty
      end

      context 'signed with the first cert' do
        it 'attempts the decoding once' do
          expect(JWT).to receive(:decode).once
          subject.perform!
        end
      end
    end

    context 'with a token having an expired signature' do
      before do
        allow(JWT).to receive(:decode)
          .with(*example_jwt_decode_params)
          .and_raise(JWT::ExpiredSignature)
      end

      it 'does not return the payload' do
        expect(subject.perform!.first).to be_blank
      end

      it 'does not return the header' do
        expect(subject.perform!.second).to be_blank
      end

      it 'returns a list of decoding errors including "signature expired"' do
        expect(subject.perform!.last).to include 'signature expired'
      end

      it 'does not attempt to continue decoding with aditional certs' do
        expect(JWT).to receive(:decode).once
        subject.perform!
      end
    end
  end
end
