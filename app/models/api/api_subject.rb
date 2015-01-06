module API
  class APISubject < Sequel::Model
    include Accession::Principal

    many_to_many :roles, class: 'Role'

    def permissions
      roles.flat_map { |role| role.permissions.map(&:value) }
    end

    def functioning?
      enabled
    end

    def validate
      validates_presence [:x509_cn, :description,
                          :contact_name, :contact_mail, :enabled,
                          :created_at, :updated_at]
    end
  end
end