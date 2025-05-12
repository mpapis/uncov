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

  describe 'report DiffLines (default)' do
    context 'when changed file' do
      let(:args) { %w[--target develop --simplecov-file coverage/coverage.json --context 2] }

      context 'when missing coverage', branch: 'develop_a_coverage_json' do
        it 'reports uncovered changed lines from diff' do
          expect { start }
            .to not_output.to_stderr_from_any_process
            .and output(<<~OUTPUT).to_stdout_from_any_process
              \e[0;33;49mFiles with uncovered changes: (1 / 1)\e[0m

              \e[0;33;49mlib/project.rb -> 50.00% (1 / 2) changes covered, uncovered lines:\e[0m
              \e[0;32;49m16: \e[0m
              \e[0;32;49m17: def succ(a)\e[0m
              \e[0;31;49m18:   'b'\e[0m
              \e[0;32;49m19: end\e[0m

              \e[0;33;49mOverall coverage of changes: 50.00% (1 / 2)\e[0m
            OUTPUT
          expect(start).to be_falsey
        end
      end

      context 'when all covered', branch: 'test_coverage_json' do
        before { File.utime(Time.now, Time.now, 'coverage/coverage.json') }

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

  describe 'report DiffFiles' do
    let(:args) { %w[--report DiffFiles --target develop --simplecov-file coverage/coverage.json --context 2] }

    context 'when missing coverage', branch: 'develop_a_coverage_json' do
      before { File.utime(Time.now, Time.now, 'coverage/coverage.json') }

      it 'reports all uncovered lines from file' do
        expect { start }
          .to not_output.to_stderr_from_any_process
          .and output(<<~OUTPUT).to_stdout_from_any_process
            \e[0;33;49mFiles with uncovered changes: (1 / 1)\e[0m

            \e[0;33;49mlib/project.rb -> 50.00% (2 / 4) changes covered, uncovered lines:\e[0m
            \e[0;32;49m12: \e[0m
            \e[0;32;49m13: def dec(a)\e[0m
            \e[0;31;49m14:   1\e[0m
            \e[0;32;49m15: end\e[0m
            \e[0;32;49m16: \e[0m
            \e[0;32;49m17: def succ(a)\e[0m
            \e[0;31;49m18:   'b'\e[0m
            \e[0;32;49m19: end\e[0m

            \e[0;33;49mOverall coverage of changes: 50.00% (2 / 4)\e[0m
          OUTPUT
        expect(start).to be_falsey
      end
    end
  end

  describe 'report GitFiles' do
    let(:args) { %w[--report GitFiles --target develop --simplecov-file coverage/coverage.json --context 2] }

    context 'when missing coverage', branch: 'develop_coverage_json' do
      before { File.utime(Time.now, Time.now, 'coverage/coverage.json') }

      it 'reports uncovered files from git' do
        expect { start }
          .to not_output.to_stderr_from_any_process
          .and output(<<~OUTPUT).to_stdout_from_any_process
            \e[0;33;49mFiles with uncovered changes: (1 / 1)\e[0m

            \e[0;33;49mlib/project.rb -> 50.00% (1 / 2) changes covered, uncovered lines:\e[0m
            \e[0;32;49m12: \e[0m
            \e[0;32;49m13: def dec(a)\e[0m
            \e[0;31;49m14:   1\e[0m
            \e[0;32;49m15: end\e[0m

            \e[0;33;49mOverall coverage of changes: 50.00% (1 / 2)\e[0m
          OUTPUT
        expect(start).to be_falsey
      end
    end

    context 'with --nocov-ignore', branch: 'develop_nocov_coverage' do
      let(:args) { %w[--report GitFiles --target develop --simplecov-file coverage/.resultset.json --context 2 --nocov-ignore] }

      before { File.utime(Time.now, Time.now, 'coverage/.resultset.json') }

      it 'reports uncovered files from git' do
        expect { start }
          .to not_output.to_stderr_from_any_process
          .and output(<<~OUTPUT).to_stdout_from_any_process
            \e[0;33;49mFiles with uncovered changes: (1 / 1)\e[0m

            \e[0;33;49mlib/project.rb -> 66.67% (4 / 6) changes covered, uncovered lines:\e[0m
            \e[0;32;49m 1: # :nocov:\e[0m
            \e[0;32;49m 2: def inc(a)\e[0m
            \e[0;31;49m 3:   a + 1\e[0m
            \e[0;32;49m 4: end\e[0m
            \e[0;32;49m 5: \e[0m
            \e[0;32;49m 7:   return 'a' if str == 'b'\e[0m
            \e[0;32;49m 8: \e[0m
            \e[0;31;49m 9:   'b'\e[0m
            \e[0;32;49m10: end\e[0m
            \e[0;32;49m11: # :nocov:\e[0m

            \e[0;33;49mOverall coverage of changes: 66.67% (4 / 6)\e[0m
          OUTPUT
        expect(start).to be_falsey
      end
    end

    context 'with --nocov-ignore --nocov-covered', branch: 'develop_nocov_coverage' do
      let(:args) { %w[--report GitFiles --target develop --simplecov-file coverage/.resultset.json --context 2 --nocov-ignore --nocov-covered] }

      before { File.utime(Time.now, Time.now, 'coverage/.resultset.json') }

      it 'reports uncovered files from git' do
        expect { start }
          .to not_output.to_stderr_from_any_process
          .and output(<<~OUTPUT).to_stdout_from_any_process
            \e[0;33;49mFiles with uncovered changes: (1 / 1)\e[0m

            \e[0;33;49mlib/project.rb -> 44.44% (4 / 9) changes covered, uncovered lines:\e[0m
            \e[0;32;49m 1: # :nocov:\e[0m
            \e[0;34;49m 2: def inc(a)\e[0m
            \e[0;31;49m 3:   a + 1\e[0m
            \e[0;32;49m 4: end\e[0m
            \e[0;32;49m 5: \e[0m
            \e[0;34;49m 6: def prec(str)\e[0m
            \e[0;34;49m 7:   return 'a' if str == 'b'\e[0m
            \e[0;32;49m 8: \e[0m
            \e[0;31;49m 9:   'b'\e[0m
            \e[0;32;49m10: end\e[0m
            \e[0;32;49m11: # :nocov:\e[0m

            \e[0;33;49mOverall coverage of changes: 44.44% (4 / 9)\e[0m
          OUTPUT
        expect(start).to be_falsey
      end
    end

    context 'with --nocov-covered', branch: 'develop_nocov_coverage' do
      let(:args) { %w[--report GitFiles --target develop --simplecov-file coverage/.resultset.json --context 2 --nocov-covered] }

      before { File.utime(Time.now, Time.now, 'coverage/.resultset.json') }

      it 'reports uncovered files from git' do
        expect { start }
          .to not_output.to_stderr_from_any_process
          .and output(<<~OUTPUT).to_stdout_from_any_process
            \e[0;33;49mFiles with uncovered changes: (1 / 1)\e[0m

            \e[0;33;49mlib/project.rb -> 66.67% (6 / 9) changes covered, uncovered lines:\e[0m
            \e[0;32;49m1: # :nocov:\e[0m
            \e[0;34;49m2: def inc(a)\e[0m
            \e[0;32;49m3:   a + 1\e[0m
            \e[0;32;49m4: end\e[0m
            \e[0;32;49m5: \e[0m
            \e[0;34;49m6: def prec(str)\e[0m
            \e[0;34;49m7:   return 'a' if str == 'b'\e[0m
            \e[0;32;49m8: \e[0m
            \e[0;32;49m9:   'b'\e[0m

            \e[0;33;49mOverall coverage of changes: 66.67% (6 / 9)\e[0m
          OUTPUT
        expect(start).to be_falsey
      end
    end
  end

  describe 'report NocovLines --nocov-covered', branch: 'develop_nocov_coverage' do
    let(:args) { %w[--report NocovLines --target develop --simplecov-file coverage/.resultset.json --context 5 --nocov-covered] }

    before { File.utime(Time.now, Time.now, 'coverage/.resultset.json') }

    it 'reports uncovered files from git' do
      expect { start }
        .to not_output.to_stderr_from_any_process
        .and output(<<~OUTPUT).to_stdout_from_any_process
          \e[0;33;49mFiles with uncovered changes: (1 / 1)\e[0m

          \e[0;33;49mlib/project.rb -> 40.00% (2 / 5) changes covered, uncovered lines:\e[0m
          \e[0;32;49m 1: # :nocov:\e[0m
          \e[0;34;49m 2: def inc(a)\e[0m
          \e[0;32;49m 3:   a + 1\e[0m
          \e[0;32;49m 4: end\e[0m
          \e[0;32;49m 5: \e[0m
          \e[0;34;49m 6: def prec(str)\e[0m
          \e[0;34;49m 7:   return 'a' if str == 'b'\e[0m
          \e[0;32;49m 8: \e[0m
          \e[0;32;49m 9:   'b'\e[0m
          \e[0;32;49m10: end\e[0m
          \e[0;32;49m11: # :nocov:\e[0m
          \e[0;32;49m12: \e[0m

          \e[0;33;49mOverall coverage of changes: 40.00% (2 / 5)\e[0m
        OUTPUT
      expect(start).to be_falsey
    end
  end
end
