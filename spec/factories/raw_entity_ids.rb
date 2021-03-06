# frozen_string_literal: true

FactoryBot.define do
  factory :raw_entity_id, class: 'EntityId' do
    uri { "#{Faker::Internet.url}/shibboleth" }
    association :raw_entity_descriptor
  end
end
