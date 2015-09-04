require 'implicit_schema'
require 'sequel'

class UpdateFromFederationRegistry
  include QueryFederationRegistry
  include StoreFederationRegistryData

  include ETL::Contacts
  include ETL::Organizations
  include ETL::EntityDescriptors

  attr_reader :fr_source, :source

  def self.perform(id)
    new(id).perform
  end

  def initialize(id)
    @cache = {}
    @fr_source = FederationRegistrySource[id]
    @source = @fr_source.entity_source
  end

  def perform
    Sequel::Model.db.transaction do
      contacts
      organizations
    end
  end
end