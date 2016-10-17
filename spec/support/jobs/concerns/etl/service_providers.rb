# frozen_string_literal: true
RSpec.shared_examples 'ETL::ServiceProviders' do
  include_examples 'ETL::Common'

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def create_json(sp)
    {
      id: sp.id,
      display_name: Faker::Lorem.sentence,
      description: description,
      functioning: sp.functioning?,
      created_at: sp_created_at,
      saml: {
        authnrequests_signed: sp.authn_requests_signed,
        assertions_signed: sp.want_assertions_signed,
        attribute_consuming_services:
          sp.attribute_consuming_services.map do |as|
            {
              is_default: as.default,
              names: as.service_names,
              descriptions: as.service_descriptions,
              attributes:
                attribute_instances.map { |ra| requested_attribute_json(ra) }
            }
          end,
        assertion_consumer_services:
          sp.assertion_consumer_services.map do |acs|
            indexed_endpoint_json(acs)
          end,
        discovery_response_services:
          sp.discovery_response_services.map do |drs|
            indexed_endpoint_json(drs)
          end,
        sso_descriptor: {
          role_descriptor: {
            protocol_support_enumerations:
              sp.protocol_supports.map { |pse| saml_uri_json(pse) },
            key_descriptors:
              sp.key_descriptors.map { |kd| key_descriptor_json(kd) }
                .push(bad_key_descriptor_json),
            contact_people:
              contact_instances.map { |cp| contact_person_json(cp) },
            error_url: sp.error_url
          },
          name_id_formats:
            sp.name_id_formats.map { |nidf| saml_uri_json(nidf) },
          artifact_resolution_services:
            sp.artifact_resolution_services.map do |ars|
              indexed_endpoint_json(ars)
            end,
          single_logout_services:
            sp.single_logout_services.map { |slo| endpoint_json(slo) },
          manage_nameid_services:
            sp.manage_name_id_services.map { |mnids| endpoint_json(mnids) }
        }
      }
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def requested_attribute_json(ra)
    {
      id: ra[:id],
      name: Faker::Lorem.word,
      is_required: false,
      reason: Faker::Lorem.word,
      values: []
    }
  end

  def attribute_base_json(a)
    {
      id: a[:id],
      description: a[:description],
      oid: a[:oid],
      name_format: {
        uri: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
      }
    }
  end

  def fr_object(name, id)
    FederationRegistryObject.create(internal_class_name: name,
                                    internal_id: id, fr_id: id)
  end

  def run
    described_class.new(id: fr_source.id)
                   .service_providers(entity_descriptor, ed_data)
  end

  let(:service_provider_instances) do
    create_list(:sp_sso_descriptor, sp_count,
                :with_authn_requests_signed,
                :with_want_assertions_signed,
                :request_attributes,
                :with_ui_info,
                :with_discovery_response_services,
                :with_key_descriptors,
                :with_single_logout_services,
                :with_manage_name_id_services,
                :with_name_id_formats,
                :with_artifact_resolution_services)
  end

  let(:service_providers_list) do
    service_provider_instances.map { |sp| create_json(sp) }
  end

  let(:service_providers) { service_providers_list }

  let(:sp_created_at) { Time.at(rand(Time.now.utc.to_i)) }

  let(:entity_descriptor) { create :entity_descriptor }

  let(:ed_data) do
    {
      saml: {
        service_providers:
          service_provider_instances.map do |sp|
            { id: sp.id, functioning: sp.functioning? }
          end
      }
    }
  end

  let(:attribute_instances) do
    (0...attribute_count).map do |i|
      {
        id: i,
        description: Faker::Lorem.sentence,
        oid: "#{Faker::Number.number(4)}:#{Faker::Number.number(4)}"
      }
    end
  end

  let(:attributes_list) do
    attribute_instances.map { |a| attribute_base_json(a) }
  end

  let(:attributes) { attributes_list }

  before do
    stub_fr_request(:contacts)
    contact_instances.each { |c| fr_object(Contact.name, c.id) }

    stub_fr_request(:attributes)
    stub_fr_request(:service_providers)
  end

  context 'creating an SPSSODescriptor' do
    let(:source_sp) { service_provider_instances.first }
    let(:sp_count) { 1 }
    let(:contact_count) { 2 }
    let(:attribute_count) { 3 }

    subject { SPSSODescriptor.last }

    it 'creates a new instance' do
      expect { run }.to change { SPSSODescriptor.count }.by(sp_count)
    end

    it 'creates a new tag' do
      expect { run }
        .to change { Tag.count }.by(1)
    end

    it 'creates a new AttributeConsumingService ' do
      expect { run }.to change { AttributeConsumingService.count }.by(sp_count)
    end

    context 'created instance' do
      before { run }

      it 'requests expected number of attributes' do
        run
        expect(AttributeConsumingService.last.reload.requested_attributes.size)
          .to eq(attribute_count)
      end

      context 'assertion_consumer_services' do
        include_examples 'indexed_endpoint' do
          let(:target) { subject.assertion_consumer_services }
          let(:source) { source_sp.assertion_consumer_services }
        end
      end

      context 'discovery_response_services' do
        include_examples 'indexed_endpoint' do
          let(:target) { subject.discovery_response_services }
          let(:source) { source_sp.discovery_response_services }
        end
      end

      context 'protocol supports' do
        include_examples 'saml_uris' do
          let(:target) { subject.protocol_supports }
          let(:source) { source_sp.protocol_supports }
        end
      end

      context 'key descriptors' do
        include_examples 'key_descriptors' do
          let(:target) { subject.key_descriptors }
          let(:source) { source_sp.key_descriptors }
        end
      end

      context 'contact people' do
        include_examples 'contact_people' do
          let(:target) { subject.entity_descriptor.contact_people }
          let(:source) do
            service_providers
              .first[:saml][:sso_descriptor][:role_descriptor][:contact_people]
          end
        end
      end

      context 'nameid formats' do
        include_examples 'saml_uris' do
          let(:target) { subject.name_id_formats }
          let(:source) { source_sp.name_id_formats }
        end
      end

      context 'artifact resolution services' do
        include_examples 'indexed_endpoint' do
          let(:target) { subject.artifact_resolution_services }
          let(:source) { source_sp.artifact_resolution_services }
        end
      end

      context 'single logout services' do
        include_examples 'endpoint' do
          let(:target) { subject.single_logout_services }
          let(:source) { source_sp.single_logout_services }
        end
      end

      context 'manage nameid services' do
        include_examples 'endpoint' do
          let(:target) { subject.manage_name_id_services }
          let(:source) { source_sp.manage_name_id_services }
        end
      end
    end
  end

  context 'updating an SPSSODescriptor' do
    subject { SPSSODescriptor.last }

    let(:sp_count) { 1 }
    let(:contact_count) { 2 }
    let(:attribute_count) { 3 }

    before { run }

    include_examples 'updating an SSODescriptor'
    include_examples 'updating MDUI content'

    it 'uses the existing instance' do
      expect { run }.not_to change { SPSSODescriptor.count }
    end

    it 'does not create more tags' do
      expect { run }.not_to change { Tag.count }
    end

    it 'updates assertion_consumer_services' do
      expect { run }.to change { subject.reload.assertion_consumer_services }
    end

    it 'updates discovery_response_services' do
      expect { run }.to change { subject.reload.discovery_response_services }
    end

    it 'updates attribute_consuming_services' do
      expect { run }.to change { subject.reload.attribute_consuming_services }
    end
  end
end
