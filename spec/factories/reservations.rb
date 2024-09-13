FactoryBot.define do
  factory :reservation do
    check_in { "2024-09-13 16:45:49" }
    check_out { "2024-09-14 16:45:49" }
    association :user
    association :room
  end
end
