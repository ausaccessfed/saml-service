# frozen_string_literal: true

FactoryBot.define do
  factory :organization_display_name, class: 'OrganizationDisplayName',
                                      parent: :localized_name do
    association :organization
  end
end
