# frozen_string_literal: true

class IdentityToken
  #= IdentityToken::Validator
  #
  # Performs the validations for a given Identity Token
  class Validator < ActiveModel::Validator
    ISSUER_PREFIX = 'https://securetoken.google.com/'

    def validate(record)
      token_decoded_successfully(record)
      token_issuer_matches_expected_issuer(record)
      token_audience_matches_expected_audience(record)
      logger.warn record.errors.full_messages.inspect if record.errors.any?
    end

    delegate :logger, to: Rails
    delegate :token_decoded_successfully,
             :token_issuer_matches_expected_issuer,
             :token_audience_matches_expected_audience,
             to: :class

    class << self
      def expected_audience
        GoogleCloudSdkHelper.project_id
      end

      def expected_issuer
        "#{ISSUER_PREFIX}#{expected_audience}"
      end

      def token_decoded_successfully(record)
        return if record.decoding_errors.blank?

        record.decoding_errors.each do |err|
          record.errors.add :token, err
        end
      end

      def token_audience_matches_expected_audience(record)
        return if record.audience == expected_audience

        record.errors.add :audience, 'mismatch'
      end

      def token_issuer_matches_expected_issuer(record)
        return if record.issuer == expected_issuer

        record.errors.add :issuer, 'mismatch'
      end
    end
  end
end
