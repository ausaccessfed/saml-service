module MDATTR
  class EntityAttribute < Sequel::Model
    include Parents

    many_to_one :entities_descriptor, class: 'EntitiesDescriptor'
    many_to_one :entity_descriptor, class: 'EntityDescriptor'

    one_to_many :attributes, class: 'Attribute'

    def validate
      super
      validates_presence [:created_at, :updated_at]
      return if new?

      validates_presence :attributes
      single_parent [:entities_descriptor, :entity_descriptor]
    end
  end
end
