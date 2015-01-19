require 'rails_helper'

require 'metadata/saml'

RSpec.describe Metadata::SAML do
  subject do
    Metadata::SAML.new(federation_identifier: federation_identifier,
                       metadata_name: metadata_name,
                       metadata_validity_period: metadata_validity_period)
  end

  let(:federation_identifier) { Faker::Internet.domain_word }
  let(:metadata_name) { "urn:mace:#{federation_identifier}.edu:test" }
  let(:metadata_validity_period) { 1.weeks }

  let(:builder) { subject.builder }
  let(:raw_xml) { builder.to_xml }
  let(:xml) do
    # Pull out xmlns so our tests don't need to specify it everywhere
    # as we expect metadata nodes to live under this namespace by default
    raw_xml.sub!('xmlns="urn:oasis:names:tc:SAML:2.0:metadata"', '')
    Capybara::Node::Simple.new(Nokogiri::XML.parse(raw_xml))
  end

  # Nodes which by schema may validly appear in multiple locations
  let(:all_publication_infos) { '//mdrpi:PublicationInfo' }

  context 'SAML namespaces' do
    include_examples 'SAML namespaces'
  end

  context 'EntitiesDescriptors' do
    let(:entities_descriptor) { create :basic_federation }
    include_examples 'EntitiesDescriptor xml'
  end

  context 'KeyInfo' do
    let(:key_info) { create :key_info }
    before { subject.key_info(key_info) }
    include_examples 'KeyInfo xml'
  end

  context 'PublisherInfo' do
    let(:entities_descriptor) { create(:basic_federation) }
    let(:entity_descriptor) do
      create(:entity_descriptor, :with_publication_info)
    end
    context 'EntitiesDescriptor' do
      before { subject.publication_info(entities_descriptor) }
      include_examples 'mdrpi:PublisherInfo xml' do
        let(:root_node) { entities_descriptor }
      end
    end
    context 'EntityDescriptor' do
      before { subject.publication_info(entity_descriptor) }
      include_examples 'mdrpi:PublisherInfo xml' do
        let(:root_node) { entity_descriptor }
      end
    end
  end

  context 'EntityDescriptors' do
    include_examples 'EntityDescriptor xml'
  end

  context 'RegistrationInfo' do
    let(:entities_descriptor) do
      create(:entities_descriptor, :with_registration_info)
    end
    let(:entity_descriptor) { create(:entity_descriptor) }
    context 'EntitiesDescriptor' do
      before { subject.registration_info(entities_descriptor) }
      include_examples 'mdrpi:RegistrationInfo xml' do
        let(:root_node) { entities_descriptor }
      end
    end
    context 'EntityDescriptor' do
      before { subject.registration_info(entity_descriptor) }
      include_examples 'mdrpi:RegistrationInfo xml' do
        let(:root_node) { entity_descriptor }
      end
    end
  end

  context 'Organization' do
    let(:organization) do
      create :organization, :with_multiple_organization_languages
    end
    before { subject.organization(organization) }
    include_examples 'Organization xml'
  end

  context 'ContactPerson' do
    let(:contact_person) { create :contact_person }
    before { subject.contact_person(contact_person) }
    include_examples 'ContactPerson xml'
  end

  context 'EntityAttribute' do
    let(:entity_attribute) { create :mdattr_entity_attribute }
    before { subject.entity_attribute(entity_attribute) }
    include_examples 'mdattr:EntityAttribute xml'
  end

  it 'attribute'
  it 'attribute value'
end
