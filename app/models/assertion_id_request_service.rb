class AssertionIdRequestService < Endpoint
  include DualOwners

  many_to_one :idp_sso_descriptor
  many_to_one :attribute_authority_descriptor

  def validate
    super
    return if new?

    valid_owner [:idp_sso_descriptor, :attribute_authority_descriptor]
  end
end
