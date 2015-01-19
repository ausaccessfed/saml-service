RSpec.shared_examples 'mdattr:EntityAttribute xml' do
  let(:entity_attribute_path) { '/mdattr:EntityAttributes' }
  let(:attribute_path) { "#{entity_attribute_path}/saml:Attribute" }

  it 'is created' do
    expect(xml).to have_xpath(entity_attribute_path, count: 1)
  end

  context 'attributes' do
    it 'creates single attribute node' do
      expect(xml).to have_xpath(attribute_path, count: 1)
    end

    context 'multiple attributes' do
      let(:entity_attribute) do
        create :mdattr_entity_attribute, :with_multiple_attributes
      end
      it 'creates attribute nodes' do
        expect(xml).to have_xpath(attribute_path, count: 3)
      end
    end
  end

  context 'REFEDS Research and Scholarship Entity Category' do
    let(:entity_attribute) do
      create :mdattr_entity_attribute, :with_refeds_rs_entity_category
    end

    it 'creates the expected saml:Attribute and saml:AttributeValue' do
      refeds_attribute_path = "#{attribute_path}" \
        "[@Name='http://macedir.org/entity-category'" \
        " and @NameFormat='urn:oasis:names:tc:SAML:2.0:attrname-format:uri']" \
        '/saml:AttributeValue' \
        "[text()='http://refeds.org/category/research-and-scholarship']"
      expect(xml).to have_xpath(refeds_attribute_path, count: 1)
    end
  end
end
