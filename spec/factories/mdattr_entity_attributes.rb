FactoryGirl.define do
  factory :mdattr_entity_attribute, class: 'MDATTR::EntityAttribute' do
    transient { provides_attribute false }

    trait :with_multiple_attributes do
      transient { provides_attribute true }
      after(:create) do |ea|
        create_list :attribute, 3, :with_value, entity_attribute: ea
      end
    end

    trait :with_refeds_rs_entity_category do
      transient { provides_attribute true }
      after(:create) do | ea |
        ea.add_attribute create(:attribute, :with_value,
                                value: 'http://refeds.org/category/research-and-scholarship',
                                name: 'http://macedir.org/entity-category')
      end
    end

    after(:create) do | ea, ev |
      ea.add_attribute create :attribute unless ev.provides_attribute
    end
  end
end
