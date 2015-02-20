class MetadataInstance < Sequel::Model
  one_to_many :entity_descriptors
  one_to_many :ca_key_infos

  one_to_one :registration_info, class: 'MDRPI::RegistrationInfo'
  one_to_one :publication_info, class: 'MDRPI::PublicationInfo'
  one_to_one :entity_attribute, class: 'MDATTR::EntityAttribute'

  def validate
    super
    validates_presence [:name, :created_at, :updated_at]
    validates_presence :ca_verify_depth if ca_key_infos.present?
    validates_presence :publication_info unless new?
  end
end