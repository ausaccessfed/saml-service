# frozen_string_literal: true
class Tag < Sequel::Model
  URL_SAFE_BASE_64_ALPHABET = /^[a-zA-Z0-9_-]+$/

  include Parents
  plugin :validation_helpers
  many_to_one :known_entity

  def validate
    super
    validates_unique([:name, :known_entity])
    validates_presence [:known_entity, :name, :created_at, :updated_at]
    validates_format(URL_SAFE_BASE_64_ALPHABET,
                     :name, message: 'is not in base64 urlsafe alphabet')
  end

  IDP = 'idp'
  AA = 'aa'
  STANDALONE_AA = 'standalone-aa'
  SP = 'sp'
end
