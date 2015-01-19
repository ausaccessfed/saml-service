require 'metadata/saml_namespaces'

module Metadata
  class SAML
    include SAMLNamespaces

    attr_reader :builder, :created_at, :expires_at, :instance_id,
                :federation_identifier, :metadata_name,
                :metadata_validity_period

    def initialize(params)
      params.each do |k, v|
        instance_variable_set("@#{k}", v)
      end

      @builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8')
      @created_at = Time.now.utc
      @expires_at = created_at + metadata_validity_period
      @instance_id = "#{federation_identifier}" \
                     "#{created_at.to_formatted_s(:number)}"
    end

    def root_entities_descriptor(entities_descriptor)
      attributes = { ID: instance_id,
                     Name: metadata_name,
                     validUntil: expires_at.xmlschema }

      entities_descriptor(entities_descriptor, attributes, true)
    end

    def entities_descriptor(entities_descriptor, attributes = {},
                            root_node = false)
      root.EntitiesDescriptor(ns, attributes) do |_|
        entities_descriptor_extensions(entities_descriptor, root_node)
        entities_descriptor.entities_descriptors.each do |ed|
          entities_descriptor(ed)
        end
        entities_descriptor.entity_descriptors.each do |ed|
          entity_descriptor(ed)
        end
      end
    end

    def entities_descriptor_extensions(ed, root_node)
      return unless ed.ca_keys? || ed.registration_info? ||
                    ed.entity_attribute? || root_node
      root.Extensions do |_|
        publication_info(ed) if root_node
        registration_info(ed) if ed.registration_info?
        key_authority(ed) if ed.ca_keys?
        entity_attribute(ed) if ed.entity_attribute?
      end
    end

    def key_authority(ed)
      shibmd.KeyAuthority(VerifyDepth: ed.ca_verify_depth) do |_|
        ed.ca_key_infos.each do |ca|
          key_info(ca)
        end
      end
    end

    def key_info(ki)
      ds.KeyInfo(ns) do |_|
        ds.KeyName ki.key_name if ki.key_name
        ds.X509Data do |_|
          ds.X509SubjectName ki.subject if ki.subject
          ds.X509Certificate ki.certificate_without_anchors
        end
      end
    end

    def publication_info(ed)
      publication_info = ed.locate_publication_info
      mdrpi.PublicationInfo(ns,
                            publisher: publication_info.publisher,
                            creationInstant: created_at.xmlschema,
                            publicationId: instance_id) do |_|
        publication_info.usage_policies.each do |up|
          mdrpi.UsagePolicy(lang: up.lang) do |_|
            root.text up.uri
          end
        end
      end
    end

    def entity_attribute(_ed)
      mdattr.EntityAttributes(ns)
    end

    def root_entity_descriptor(ed)
      attributes = { ID: instance_id,
                     validUntil: expires_at.xmlschema }
      entity_descriptor(ed, attributes, true)
    end

    def entity_descriptor(ed, attributes = {}, root_node = false)
      root.EntityDescriptor(ns, attributes, entityID: ed.entity_id.uri) do |_|
        entity_descriptor_extensions(ed, root_node)

        ed.idp_sso_descriptors.each do |idp|
          idp_sso_descriptor(idp)
        end
        ed.sp_sso_descriptors.each do |sp|
          sp_sso_descriptor(sp)
        end
        ed.attribute_authority_descriptors.each do |aad|
          attribute_authority_descriptor(aad)
        end

        organization(ed.organization)
        ed.contact_people.each do |cp|
          contact_person(cp)
        end
      end
    end

    def entity_descriptor_extensions(ed, root_node)
      root.Extensions do |_|
        publication_info(ed) if root_node
        registration_info(ed)
        entity_attribute(ed) if ed.entity_attribute?
      end
    end

    def registration_info(ed)
      attributes = {
        registrationAuthority: ed.registration_info.registration_authority,
        registrationInstant: ed.registration_info
                             .registration_instant_utc.xmlschema
      }
      mdrpi.RegistrationInfo(ns, attributes) do |_|
        ed.registration_info.registration_policies.each do |rp|
          mdrpi.RegistrationPolicy(lang: rp.lang) do |_|
            root.text rp.uri
          end
        end
      end
    end

    def organization(org)
      root.Organization(ns) do |_|
        org.organization_names.each do |name|
          root.OrganizationName(lang: name.lang) do |_|
            root.text name.value
          end
        end
        org.organization_display_names.each do |dname|
          root.OrganizationDisplayName(lang: dname.lang) do |_|
            root.text dname.value
          end
        end
        org.organization_urls.each do |url|
          root.OrganizationURL(lang: url.lang) do |_|
            root.text url.uri
          end
        end
      end
    end

    def contact_person(cp)
      attributes = { contactType: cp.contact_type }
      c = cp.contact
      root.ContactPerson(ns, attributes) do |_|
        root.Company { root.text c.company } if c.company
        root.GivenName { root.text c.given_name } if c.given_name
        root.SurName { root.text c.surname } if c.surname

        if c.email_address
          root.EmailAddress { root.text "mailto:#{c.email_address}" }
        end
        if c.telephone_number
          root.TelephoneNumber { root.text c.telephone_number }
        end
      end
    end

    def idp_sso_descriptor(_idp)
      root.IDPSSODescriptor(ns) do |_|
      end
    end

    def sp_sso_descriptor(_idp)
      root.SPSSODescriptor(ns) do |_|
      end
    end

    def attribute_authority_descriptor(_aad)
      root.AttributeAuthorityDescriptor(ns) do |_|
      end
    end
  end
end
