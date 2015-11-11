require 'rails_helper'

require 'gumboot/shared_examples/api_controller'

module API
  RSpec.describe APIController, type: :controller do
    include_examples 'API base controller'
  end
end
