require 'spec_helper'

describe Zf::Utils do
  describe '#to_upper_camel_case' do
    it { expect(described_class.to_upper_camel_case('aaa')).to eq 'Aaa' }

    it { expect(described_class.to_upper_camel_case('aaa_bbb')).to eq 'AaaBbb' }

    it { expect(described_class.to_upper_camel_case('aaa/bbb_ccc')).to eq 'Aaa::BbbCcc' }

    it { expect(described_class.to_upper_camel_case('aaa_bbb/ccc_ddd')).to eq 'AaaBbb::CccDdd' }
  end
end
