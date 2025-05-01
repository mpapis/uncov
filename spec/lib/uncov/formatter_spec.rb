# frozen_string_literal: true

RSpec.describe Uncov::Formatter do
  subject(:formatter_output) { described_class.output(report) }

  let(:report) { instance_double(Uncov::Report) }

  context 'when unknown output_format' do
    before { allow(Uncov.configuration).to receive(:output_format).and_return(:unknown) }

    it do
      expect { formatter_output }.to raise_error(
        Uncov::UnsupportedFormatterError, ':unknown is not a supported formatter'
      )
    end
  end
end
