# frozen_string_literal: true

#= AuthenticatedController
#
# Base class for all controllers that require an authenticated session
class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
end
