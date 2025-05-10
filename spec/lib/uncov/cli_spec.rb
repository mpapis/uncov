# frozen_string_literal: true

RSpec.describe Uncov::CLI do
  subject(:start) { described_class.start(args) }

  context 'with -v' do
    let(:args) { %w[-v] }

    it 'prints version and throws exit' do
      expect { start }
        .to throw_symbol(:exit, 0)
        .and output(/uncov [\d\.]+ by Michal/).to_stdout
    end
  end

  context 'with invalid arg' do
    let(:args) { %w[--foo] }

    it 'prints version and returns nil' do
      expect { start }.to output("invalid option: --foo\n").to_stderr
      is_expected.to be_nil
    end
  end

  context 'when changed file' do
    let(:args) { %w[--target clean --simplecov-file coverage/coverage.json --context 2] }

    context 'when missing coverage', branch: 'develop_coverage_json' do
      it 'reports changes uncovered' do
        expect { start }
          .to not_output.to_stderr_from_any_process
          .and output(<<~OUTPUT).to_stdout_from_any_process
            \e[0;33;49mFound 1 files with uncovered changes:\e[0m

            \e[0;33;49mlib/project.rb -> 50.00% (1 / 2) changes covered, uncovered lines:\e[0m
            \e[0;32;49m6: \e[0m
            \e[0;32;49m7: def dec(a)\e[0m
            \e[0;31;49m8:   1\e[0m
            \e[0;32;49m9: end\e[0m

            \e[0;33;49mOverall coverage of changes: 50.00%\e[0m
          OUTPUT
        expect(start).to be_falsey
      end
    end

    context 'when all covered', branch: 'test_coverage_json' do
      it 'reports changes covered' do
        expect { start }
          .to output("\e[0;32;49mAll changed files(1) have 100% test coverage!\e[0m\n").to_stdout_from_any_process
          .and not_output.to_stderr_from_any_process
        expect(start).to be_truthy
      end
    end
  end

  context 'without filtered files', branch: 'test_coverage_json' do
    let(:args) { %w[--target HEAD --simplecov-file coverage/coverage.json --context 2] }

    it 'reports changes covered' do
      expect { start }
        .to output("\e[0;32;49mNo files to report.\e[0m\n").to_stdout_from_any_process
        .and not_output.to_stderr_from_any_process
      expect(start).to be_truthy
    end
  end
end
