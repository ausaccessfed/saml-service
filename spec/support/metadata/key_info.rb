RSpec.shared_examples 'KeyInfo xml' do
  let(:key_info_path) { '/ds:KeyInfo' }
  let(:key_name_path) { "#{key_info_path}/ds:KeyName" }
  let(:x509_data_path) { "#{key_info_path}/ds:X509Data" }
  let(:x509_subject_name_path) { "#{x509_data_path}/ds:X509SubjectName" }
  let(:x509_certificate_path) { "#{x509_data_path}/ds:X509Certificate" }

  it 'is created' do
    expect(xml).to have_xpath(key_info_path)
  end

  context 'KeyName' do
    context 'is set' do
      let(:node) { xml.find(:xpath, key_name_path) }
      it 'is created' do
        expect(xml).to have_xpath(key_name_path)
      end
      it 'has correct value' do
        expect(node.text).to eq(key_info.key_name)
      end
    end
    context 'is not set' do
      let(:key_info) { create :key_info, key_name: nil }
      it 'is not created' do
        expect(xml).not_to have_xpath(key_name_path)
      end
    end
  end

  context 'X509Data' do
    it 'is created' do
      expect(xml).to have_xpath(x509_data_path)
    end
    context 'X509SubjectName' do
      let(:node) { xml.find(:xpath, x509_subject_name_path) }
      it 'is created' do
        expect(xml).to have_xpath(x509_subject_name_path)
      end
      it 'has correct value' do
        expect(node.text).to eq(key_info.subject)
      end
    end
    context 'X509Certificate' do
      let(:node) { xml.find(:xpath, x509_certificate_path) }
      it 'is created' do
        expect(xml).to have_xpath(x509_certificate_path)
      end
      it 'has correct value' do
        expect(node.text).to eq(key_info.certificate_without_anchors)
      end
    end
  end
end