# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "test#{n}" }
    password { 'test123' }
    role { 'user' }
  end
end
