require 'rails_helper'

module API
  RSpec.describe DiscoveryServiceQueryController, type: :request do
    let(:json) { JSON.parse(response.body, symbolize_names: true) }

    context 'get /api/discovery_service_query' do
      def run
        get '/api/discovery_service_query'
      end

      let!(:idp_sso_desc) do
        create(:idp_sso_descriptor, :with_ui_info)
      end

      let!(:sp_sso_desc) do
        create(:sp_sso_descriptor, :with_ui_info)
      end

      before(:example) { run }

      it 'lists the identity_providers' do
        idp_known_entity = idp_sso_desc.entity_descriptor.known_entity
        idp_display_name = idp_sso_desc.ui_info.display_names.first

        expect(json[:identity_providers])
          .to include(entity_id: idp_known_entity.entity_id,
                      names: include(value: idp_display_name.value,
                                     lang: idp_display_name.lang),
                      tags: idp_known_entity.tags)
      end

      it 'lists the service_providers' do
        sp_known_entity = sp_sso_desc.entity_descriptor.known_entity
        sp_display_name = sp_sso_desc.ui_info.display_names.first
        sp_disc_response = sp_sso_desc.discovery_response_services.first

        expect(json[:service_providers])
          .to include(entity_id: sp_known_entity.entity_id,
                      discovery_response: sp_disc_response,
                      names: include(value: sp_display_name.value,
                                     lang: sp_display_name.lang),
                      tags: sp_known_entity.tags)
      end
    end
  end
end
