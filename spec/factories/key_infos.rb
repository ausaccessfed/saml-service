require 'openssl'

FactoryGirl.define do
  trait :base_key_info do
    data { generate_certificate }
    key_name { Faker::Lorem.word }
    expiry Time.now + 3600

    to_create { |i| i.save }
  end

  factory :ca_key_info, class: 'CaKeyInfo', traits: [:base_key_info]
  factory :key_info do
    base_key_info
    subject { "CN=#{Faker::Internet.url}" }
    issuer { "O=#{Faker::Company.name}" }
  end
end

def generate_certificate
  key = OpenSSL::PKey::RSA.new 1024
  public_key = key.public_key

  cert = OpenSSL::X509::Certificate.new
  cert.subject = cert.issuer = OpenSSL::X509::Name.parse 'DC=example,DC=com'
  cert.not_before = Time.now
  cert.not_after = Time.now + 3600
  cert.public_key = public_key
  cert.serial = 0x0
  cert.version = 2

  cert.to_pem
end