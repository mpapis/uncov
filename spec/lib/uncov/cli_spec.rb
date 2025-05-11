# frozen_string_literal: true

RSpec.describe Uncov::CLI do
  subject(:start) { described_class.start(args) }

  context 'with invalid arg' do
    let(:args) { %w[--foo] }

    it 'prints failure' do
      expect { start }.to output("invalid option: --foo\n").to_stderr
      is_expected.to be_nil
    end
  end

  context 'with --help' do
    let(:args) { %w[--help] }

    it 'prints help and exits' do
      expect { start }
        .to throw_symbol(:exit, 0)
        .and output(/Usage: uncov \[options\]/).to_stdout
    end
  end

  describe 'report diff_lines (default)' do
    context 'when changed file' do
      let(:args) { %w[--target develop --simplecov-file coverage/coverage.json --context 2] }

      context 'when missing coverage', branch: 'develop_a_coverage_json' do
        it 'reports uncovered changed lines from diff' do
          expect { start }
            .to not_output.to_stderr_from_any_process
            .and output(<<~OUTPUT).to_stdout_from_any_process
              \e[0;33;49mFound 1 files with uncovered changes:\e[0m

              \e[0;33;49mlib/project.rb -> 50.00% (1 / 2) changes covered, uncovered lines:\e[0m
              \e[0;32;49m10: \e[0m
              \e[0;32;49m11: def succ(a)\e[0m
              \e[0;31;49m12:   'b'\e[0m
              \e[0;32;49m13: end\e[0m

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

  describe 'report diff_files' do
    let(:args) { %w[--report diff_files --target develop --simplecov-file coverage/coverage.json --context 2] }

    context 'when missing coverage', branch: 'develop_a_coverage_json' do
      before { File.utime(Time.now, Time.now, 'coverage/coverage.json') }

      it 'reports all uncovered lines from file' do
        expect { start }
          .to not_output.to_stderr_from_any_process
          .and output(<<~OUTPUT).to_stdout_from_any_process
            \e[0;33;49mFound 1 files with uncovered changes:\e[0m

            \e[0;33;49mlib/project.rb -> 50.00% (2 / 4) changes covered, uncovered lines:\e[0m
            \e[0;32;49m 6: \e[0m
            \e[0;32;49m 7: def dec(a)\e[0m
            \e[0;31;49m 8:   1\e[0m
            \e[0;32;49m 9: end\e[0m
            \e[0;32;49m10: \e[0m
            \e[0;32;49m11: def succ(a)\e[0m
            \e[0;31;49m12:   'b'\e[0m
            \e[0;32;49m13: end\e[0m

            \e[0;33;49mOverall coverage of changes: 50.00%\e[0m
          OUTPUT
        expect(start).to be_falsey
      end
    end
  end

  describe 'report git_files' do
    let(:args) { %w[--report git_files --target develop --simplecov-file coverage/coverage.json --context 2] }

    context 'when missing coverage', branch: 'develop_coverage_json' do
      before { File.utime(Time.now, Time.now, 'coverage/coverage.json') }

      it 'reports uncovered files from git' do
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
  end
end
