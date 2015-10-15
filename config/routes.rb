Rails.application.routes.draw do
  URI_REGEXP = URI.regexp(%w(http https urn:mace))
  SHA1_REGEXP = /{sha1}(.*)?/

  match '/:primary_tag/entities',
        to: 'metadata_query#all_entities', via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#specific_entity',
        constraints: { identifier: URI_REGEXP }, via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#specific_entity_sha1',
        constraints: # check regexp against decoded URI params
          -> (r) { r.path_parameters[:identifier].match(SHA1_REGEXP) },
        via: :all

  match '/:primary_tag/entities/:identifier',
        to: 'metadata_query#tagged_entities', via: :all

  # this is for test
  # match 'entities', to: 'api/entity#index', via: :get
  namespace :api, defaults: { format: 'json' } do
    get 'entities' => 'entity#index'
  end
end
