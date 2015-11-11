require 'rails_helper'

module API
  RSpec.describe DiscoveryServiceQueryController, type: :controller do
    describe 'GET #index' do
      context 'response' do
        before { get :index, format: :json }

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end

        it 'renders json response' do
          expect(response)
            .to render_template('api/discovery_service_query/index')
        end
      end

      context '.select_with_functioning' do
        let!(:idp_sso) { create(:idp_sso_descriptor) }
        let!(:sp_sso) { create(:sp_sso_descriptor) }

        before { get :index, format: :json }

        it 'selects @identity_providers with .functioning?' do
          expect(assigns(:identity_providers))
            .to include(idp_sso)
        end

        it 'selects @service_providers with .functioning?' do
          expect(assigns(:service_providers))
            .to include(sp_sso)
        end
      end

      context '.select_with_functioning' do
        let!(:idp_sso) do
          create(:idp_sso_descriptor, :with_disabled_entity_desc)
        end

        let!(:sp_sso) do
          create(:sp_sso_descriptor, :with_disabled_entity_desc)
        end

        before { get :index, format: :json }

        it 'shouldn\'t select @identity_providers with false .functioning?' do
          expect(assigns(:identity_providers))
            .not_to include(idp_sso)
        end

        it 'shouldn\'t select @service_providers with false .functioning?' do
          expect(assigns(:service_providers))
            .not_to include(sp_sso)
        end
      end
    end
  end
end
