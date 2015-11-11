# IDPSSODescriptor.all
json.identity_providers @identity_providers do |idp|
  json.entity_id idp.entity_descriptor.known_entity.entity_id

  if idp.ui_info.display_names
    json.names idp.ui_info.display_names do |name|
      json.value name.value
      json.lang name.lang
    end
  end

  json.tags idp.entity_descriptor.known_entity.tags
end

# SPSSODescriptor.all
json.service_providers @service_providers do |sp|
  json.entity_id sp.entity_descriptor.known_entity.entity_id

  first_disc_response = sp.discovery_response_services.first
  disc_response = sp.discovery_response_services.find(&:is_default)

  json.discovery_response disc_response || first_disc_response

  if sp.ui_info.display_names
    json.names sp.ui_info.display_names do |name|
      json.value name.value
      json.lang name.lang
    end
  end

  json.tags sp.entity_descriptor.known_entity.tags
end
