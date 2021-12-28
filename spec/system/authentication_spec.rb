# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Authentication', type: :system do
  scenario 'A user views the sign in form' do
    visit sign_in_path

    # We'll just test firebase UI rendering an authentication form:
    expect(page).to have_field 'Email'
    expect(page).to have_button 'Next'
  end
end
