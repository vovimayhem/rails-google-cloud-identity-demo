# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Home', type: :system do
  let(:example_user) { create :user }

  scenario 'Unauthenticated user sees the sign in form' do
    visit root_path

    # We'll just test firebase UI rendering an authentication form:
    expect(page).to have_field 'Email'
    expect(page).to have_button 'Next'
  end

  scenario 'Authenticated user sees the home page' do
    sign_in example_user
    visit root_path

    # ICALIA TIP: Use `debug` or `debug binding` instead of `debugger` in system
    # specs to pause the spec. Open 'localhost:9222' in Chrome to open the
    # project's browserless app, which should list an option to inspect the
    # spec's capybara browser session:
    #
    # debug binding

    expect(page).to have_content 'Home'
  end
end
