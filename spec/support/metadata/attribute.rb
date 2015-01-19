RSpec.shared_examples 'saml:Attribute xml' do
  let(:attribute_path) { '/saml:Attribute' }
  let(:attribute_value_path) { "#{attribute_path}/saml:AttributeValue" }

  let(:node) { xml.find(:xpath, attribute_path) }

  context 'Attribute' do
    it 'is created' do
      expect(xml).to have_xpath(attribute_path, count: 1)
    end

    context 'attributes' do
      it 'sets Name' do
        expect(node['Name']).to eq(attribute.name)
      end

      context 'NameFormat' do
        context 'without value' do
          let(:attribute) { create :minimal_attribute }
          it 'is not included' do
            expect(node['NameFormat']).not_to be
          end
        end
        context 'with value' do
          it 'is included' do
            expect(node['NameFormat']).to eq(attribute.name_format.uri)
          end
        end
      end

      context 'FriendlyName' do
        context 'without value' do
          let(:attribute) { create :minimal_attribute }
          it 'is not included' do
            expect(node['FriendlyName']).not_to be
          end
        end
        context 'with value' do
          let(:attribute) do
            create :minimal_attribute, friendly_name: Faker::Lorem.word
          end
          it 'is included' do
            expect(node['FriendlyName']).to eq(attribute.friendly_name)
          end
        end
      end
    end

    context 'AttributeValue' do
      let(:nodes) { xml.all(:xpath, attribute_value_path) }

      context 'Attribute has no attribute_values' do
        it 'is not created' do
          expect(xml).not_to have_xpath(attribute_value_path)
        end
      end
      context 'Attribute has attribute_values' do
        let(:attribute) { create :attribute, :with_values }
        it 'is not created' do
          expect(xml).to have_xpath(attribute_value_path, count: 3)
        end

        it 'renders expected values' do
          nodes.each_with_index do |node, i|
            expect(node.text).to eq(attribute.attribute_values[i].value)
          end
        end
      end
    end
  end
end
