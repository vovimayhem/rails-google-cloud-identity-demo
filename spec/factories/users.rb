# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:identity_platform_id) { |n| n.to_s.rjust(10, '0') }

    trait :with_email do
      sequence(:email) { |n| "user-#{n}@example.com" }
    end

    trait :with_name do
      sequence(:name) { |n| "Example User #{n}" }
    end
  end
end
