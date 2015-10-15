require 'rails_helper'

module API
  RSpec.describe EndpointEntitiesController, type: :request do
    let(:json) { JSON.parse(response.body, symbolize_names: true) }
    context 'get /api/json_entities' do
      def run
        get '/api/json_entities'
      end

      let!(:entity) { create(:known_entity) }
      before { run }

      it 'lists the entities' do
        expect(json[:entities])
          .to include(Hash)
      end
    end
  end
end
