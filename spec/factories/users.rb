# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { 'test' }
    password { 'test123' }
    role { 0 }
  end
end
