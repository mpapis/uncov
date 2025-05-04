# frozen_string_literal: true

RSpec.describe Uncov::Report do
  subject { described_class.new(files) }

  describe '#coverage' do
    subject { super().coverage }

    let(:files) { [] }

    it { is_expected.to eq(100.0) }
  end
end
