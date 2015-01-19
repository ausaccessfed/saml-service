FactoryGirl.define do
  factory :contact_person do
    contact_type :technical
    association :contact

    trait :without_company do
      association :contact, company: nil
    end
    trait :without_given_name do
      association :contact, given_name: nil
    end
    trait :without_surname do
      association :contact, surname: nil
    end
    trait :without_email_address do
      association :contact, email_address: nil
    end
    trait :without_telephone_number do
      association :contact, telephone_number: nil
    end
  end
end
