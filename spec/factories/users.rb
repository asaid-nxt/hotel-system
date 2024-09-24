# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { 'test' }
    password { 'test123' }
    first_name { 'Harry' }
    last_name { 'Kane' }
    preferences { 'Gym, Pool' }
    role { 'user' }
  end
end
