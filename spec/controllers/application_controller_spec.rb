# frozen_string_literal: true

require 'rails_helper'

require 'gumboot/shared_examples/application_controller'

RSpec.describe ApplicationController, type: :controller do
  # HACK: We can't use these examples until we can use AAF Lipstick. We're
  # currently using Sequel instead of ActiveRecord, but Lipstick requires the
  # latter, so that's not an option at this juncture.
  # include_examples 'Application controller'

  describe 'health' do
    def run
      get 'health'
    end

    it 'responds with status code 200' do
      run
      expect(response.body).to include('ok')
    end
  end
end
