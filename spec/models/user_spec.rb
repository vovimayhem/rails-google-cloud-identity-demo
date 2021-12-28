# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates the presence of the identity platform id' do
      is_expected.to validate_presence_of :identity_platform_id
    end
  end
end
