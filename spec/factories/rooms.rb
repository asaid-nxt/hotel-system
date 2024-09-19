FactoryBot.define do
  factory :room do
    sequence(:number) { |n| "#{n}" }
    capacity { 1 }
    amenities { 'Gym' }
    association :hotel
  end
end
