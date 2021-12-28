# frozen_string_literal: true

#= User
#
# Represents a user that can sign in / has signed in:
class User < ApplicationRecord
  attribute :name,                 :string
  attribute :email,                :string
  attribute :identity_platform_id, :string
  attribute :created_at,           :datetime
  attribute :updated_at,           :datetime

  validates :identity_platform_id, presence: true, uniqueness: true
end
