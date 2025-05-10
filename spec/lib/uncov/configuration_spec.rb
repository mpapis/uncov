# frozen_string_literal: true

RSpec.describe Uncov::Configuration do
  describe '.options' do
    subject(:configuration) { described_class.options }

    it { is_expected.to be_a Array }
  end

  describe '#parse_cli' do
    subject(:parse_cli) { described_class.new.parse_cli(args) }

    let(:args) { [] }

    context 'with -h' do
      let(:args) { %w[-h] }

      it 'prints help message and throws exit' do
        expect { parse_cli }
          .to throw_symbol(:exit, 0)
          .and output(/Usage: uncov \[options\]/).to_stdout
      end
    end

    context 'with -r unallowed' do
      let(:args) { %w[-r unallowed] }

      it 'raises exception' do
        allowed_types = Uncov::Report::Generator.types.map { |t| "\"#{t}\"" }.join(', ')
        expect { parse_cli }.to raise_error(
          Uncov::OptionValueNotAllowed,
          %(Configuration option("report") tried to set: "unallowed", only: [#{allowed_types}] allowed)
        )
      end
    end
  end
end
