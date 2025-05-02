# frozen_string_literal: true

RSpec.describe Uncov::CLI do
  subject(:start) { described_class.start(args) }

  let(:args) { [] }

  context 'with -v' do
    let(:args) { %w[-v] }

    it 'prints version and throws exit' do
      expect { start }
        .to throw_symbol(:exit, 0)
        .and output(/uncov [\d\.]+ by Michal/).to_stdout
    end
  end

  context 'with invalid arg' do
    let(:args) { ['--foo'] }

    it 'prints version and returns nil' do
      expect { start }.to output("invalid option: --foo\n").to_stderr
      is_expected.to be_nil
    end
  end

  context 'with changed file' do
    let(:report) { instance_double(Uncov::Report, covered?: true) }

    # TODO: switch to providing example simplecov file with full coverage
    before { allow(Uncov::Report).to receive(:new).and_return(report) }

    it 'reports uncovered changes' do
      expect { start }.to output(/All changed files have 100% test coverage!/).to_stdout
      expect(start).to be_truthy
    end
  end
end
