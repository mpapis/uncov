# frozen_string_literal: true

RSpec.describe Uncov do
  describe '.configuration' do
    subject { described_class.configuration }

    it 'creates and returns Configuration instance' do
      is_expected.to be_a(Uncov::Configuration)
    end

    it 'does cache Configuration instance' do
      is_expected.to eq(described_class.configuration)
    end
  end

  describe '.configure' do
    subject(:configure) { described_class.configure(args, &block) }

    let(:args) { [] }
    let(:block) { nil }

    after { described_class.instance_variable_set(:@configuration, nil) }

    context 'with args' do
      let(:args) { %w[--target develop] }

      it 'sets configuration target' do
        expect { configure }
          .to change { described_class.configuration.target }.from('HEAD').to('develop')
          .and not_output.to_stderr
      end
    end

    context 'with block' do
      let(:block) { ->(config) { config.target = 'develop' } }

      it 'sets configuration target' do
        expect { configure }
          .to change { described_class.configuration.target }.from('HEAD').to('develop')
          .and not_output.to_stderr
      end
    end

    context 'when debug' do
      let(:args) { %w[--debug] }

      it 'sets configuration target' do
        # different ruby version have different formatting for hashes inspect
        expect { configure }.to output(/{configuration: {.*debug(: |=>)true}}/).to_stderr
      end
    end
  end
end
