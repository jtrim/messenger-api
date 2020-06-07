FactoryBot.define do
  factory :message do
    content { 'Message content' }
    association :sender, factory: :user
    association :recipient, factory: :user
    sent_at { Time.now }

    trait :read do
      read_at { Time.now }
    end
  end
end
