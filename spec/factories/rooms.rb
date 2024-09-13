FactoryBot.define do
  factory :room do
    number { "MyString" }
    capacity { 1 }
    amenities { "MyText" }
    association :hotel
  end
end
