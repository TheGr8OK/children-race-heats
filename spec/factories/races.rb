FactoryBot.define do
  factory :race do
    sequence(:title) { |n| "Race #{n}" }
  end
end
