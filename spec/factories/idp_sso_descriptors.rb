FactoryGirl.define do
  factory :idp_sso_descriptor, parent: :sso_descriptor,
                               class: 'IDPSSODescriptor' do
    want_authn_requests_signed false

    after(:create) do |idp|
      idp.add_single_sign_on_service(create :single_sign_on_service,
                                            idp_sso_descriptor: idp)
    end

    trait :with_requests_signed do
      want_authn_requests_signed true
    end

    trait :with_multiple_single_sign_on_services do
      after(:create) do |idp|
        create_list(:single_sign_on_service, 2, idp_sso_descriptor: idp)
      end
    end

    trait :with_assertion_id_request_services do
      after(:create) do |idp|
        create_list(:assertion_id_request_service, 2, idp_sso_descriptor: idp)
      end
    end

    trait :with_name_id_mapping_services do
      after(:create) do |idp|
        create_list(:name_id_mapping_service, 2, idp_sso_descriptor: idp)
      end
    end

    trait :with_attribute_profiles do
      after(:create) do |idp|
        create_list(:attribute_profile, 2, idp_sso_descriptor: idp)
      end
    end

    trait :with_attributes do
      after(:create) do |idp|
        create_list(:attribute, 2, idp_sso_descriptor: idp)
      end
    end

    trait :with_ui_info do
      after(:create) do |idp|
        idp.ui_info = create :mdui_ui_info, :with_content, role_descriptor: idp
      end
    end

    trait :with_disco_hints do
      after(:create) do |idp|
        idp.disco_hints = create :mdui_disco_hint
      end
    end

    trait :with_disabled_entity_desc do
      association :entity_descriptor, enabled: false
    end
  end
end
