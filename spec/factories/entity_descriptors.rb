FactoryGirl.define do
  factory :entity_descriptor do
    association :entities_descriptor
    association :organization

    after :create do |ed|
      ed.entity_id = create :entity_id, entity_descriptor: ed
      ed.add_contact_person create :contact_person, entity_descriptor: ed
      ed.registration_info = create :mdrpi_registration_info
    end

    trait :with_publication_info do
      after(:create) do | ed |
        ed.publication_info = create :mdrpi_publication_info
      end
    end

    trait :with_entity_attribute do
      after(:create) do | ed |
        ed.entity_attribute = create :mdattr_entity_attribute
      end
    end

    trait :with_refeds_rs_entity_category do
      after(:create) do | ed |
        ed.entity_attribute = create :mdattr_entity_attribute,
                                     :with_refeds_rs_entity_category
      end
    end
  end
end
