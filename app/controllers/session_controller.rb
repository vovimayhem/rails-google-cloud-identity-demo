# frozen_string_literal: true

#= SessionController
#
# Handles the user session, siging-in and signing-out
class SessionController < ApplicationController
  def new; end

  def create
    token = IdentityToken.load(session_params[:token])

    if token.valid? && sign_in_user(token.find_or_create_subject)
      redirect_to after_sign_in_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out_user
    redirect_to new_session_path
  end

  private

  def session_params
    params.require(:session).permit :token
  end
end
