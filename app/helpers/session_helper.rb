# frozen_string_literal: true

#= SessionHelper
#
# Helper methods used to manage the user session
module SessionHelper
  def warden
    request.env['warden']
  end

  def user_signed_in?(...)
    warden.authenticated?(...)
  end

  def authenticate_user!(...)
    session[:after_sign_in_path] = request.path unless user_signed_in?(...)
    warden.authenticate!(...)
  end

  def after_sign_in_path
    session.delete(:after_sign_in_path) || root_path
  end

  def sign_in_user(user, scope: :default)
    warden.set_user(user, scope: scope)
  end

  def sign_out_user(scope: nil)
    session.delete :last_visited_profile_id

    if scope
      warden.logout(scope)
      warden.clear_strategies_cache!(scope: scope)
    else
      warden.logout
      warden.clear_strategies_cache!
    end
  end

  def current_user(...)
    warden.user(...)
  end
end
