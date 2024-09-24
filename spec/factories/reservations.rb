FactoryBot.define do
  factory :reservation do
    check_in { Date.today }
    check_out { Date.tomorrow }
    association :user
    association :room
  end
end
