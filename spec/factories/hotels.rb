FactoryBot.define do
  factory :hotel do
    sequence(:name) { |n| "MyString#{n}" }
    location { "MyString" }
    amenities { "MyText" }
  end
end
