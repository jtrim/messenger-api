FactoryBot.define do
  factory :contact do
    association :owner, factory: :user
    association :user
    active { true }

    trait :inactive do
      active { false }
      active_updated_at { Time.now }
    end
  end
end
