# frozen_string_literal: true

require 'api_constraints'

Rails.application.routes.draw do
  SHA1_REGEXP = /{sha1}(.*)?/.freeze
  URN_REGEXP = /(http|https|urn)(.*)?/.freeze

  scope '/mdq' do
    match '/:instance/entities',
          to: 'metadata_query#all_entities', via: :all

    match '/:instance/entities/:identifier',
          to: 'metadata_query#specific_entity_sha1',
          constraints: # check regexp against decoded URI params
            ->(r) { r.path_parameters[:identifier].match(SHA1_REGEXP) },
          via: :all

    match '/:instance/entities/:identifier',
          to: 'metadata_query#tagged_entities',
          constraints:
            ->(r) { !r.path_parameters[:identifier].match(URN_REGEXP) },
          via: :all

    match '/:instance/entities/*identifier',
          to: 'metadata_query#specific_entity',
          constraints: { identifier: /.*/ }, via: :all
  end

  match '/health',
        to: 'application#health',
        via: :all

  namespace :api, defaults: { format: 'json' } do
    scope constraints: APIConstraints.new(version: 1, default: true) do
      scope 'discovery' do
        resources :discovery_entities, path: 'entities'
      end
      patch 'entity_sources/:tag/raw_entity_descriptors/'\
            ':base64_urlsafe_entity_id',
            to: 'raw_entity_descriptors#update',
            as: 'raw_entity_descriptors'
    end
  end
end
