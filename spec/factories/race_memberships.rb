FactoryBot.define do
  factory :race_membership do
    race { nil }
    student { create(:student) }
    sequence(:lane_number) { |n| n }
  end
end

