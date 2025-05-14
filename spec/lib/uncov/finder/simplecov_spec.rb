# frozen_string_literal: true

RSpec.describe Uncov::Finder::Simplecov do
  subject(:simplecov_files) { described_class.files(trigger_files) }

  before { allow(Uncov.configuration).to receive(:target).and_return('clean') }

  let(:trigger_files) { %w[lib/project.rb spec/lib/project_spec.rb] }

  context 'when coverage file missing', branch: 'test' do
    context 'and regenerate fails' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'coverage/coverage.json',
          test_command: 'false'
        )
      end

      it 'runs rspec and raises' do
        expect { simplecov_files }
          .to not_output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
          .and raise_error(Uncov::FailedToGenerateReport, 'Command failed with exit 1: false')
      end
    end

    context 'and is not regenerated' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'coverage/coverage.json',
          test_command: 'COVERAGE=1 rspec'
        )
      end

      it 'runs rspec and raises' do
        expect { simplecov_files }
          .to output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
          .and raise_error(Uncov::MissingSimplecovReport, 'SimpleCov results not found at "coverage/coverage.json"')
      end
    end

    context 'and is not autodetected/regenerated' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'autodetect',
          test_command: 'echo "Coverage report generated for RSpec .*spec/fixtures/project/coverage"'
        )
      end

      it 'runs rspec and raises' do
        expect { simplecov_files }
          .to output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
          .and raise_error(Uncov::AutodetectSimplecovPathError, 'Could not autodetect coverage report path')
      end
    end

    context 'and is regenerated' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'coverage/coverage.json',
          test_command: 'COVERAGE_JSON=1 rspec'
        )
      end

      it 'runs rspec and returns files' do
        expect do
          expect(simplecov_files).to include('lib/project.rb')
        end
          .to output(%r{^JSON Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
      end
    end
  end

  context 'when resultset coverage file missing', branch: 'test' do
    before do
      allow(Uncov.configuration).to receive_messages(
        simplecov_file: 'coverage/.resultset.json',
        test_command: 'COVERAGE=1 rspec'
      )
    end

    it 'runs rspec and returns files' do
      expect do
        expect(simplecov_files).to include('lib/project.rb')
      end
        .to output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
    end
  end

  context 'when coverage file exists', branch: 'test_coverage_resultset' do
    context 'and is autodetected' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'autodetect',
          test_command: 'COVERAGE=1 rspec'
        )
        File.utime(Time.now, Time.now, 'coverage/.resultset.json')
      end

      it 'returns files' do
        expect do
          expect(simplecov_files).to include('lib/project.rb')
        end
          .to not_output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
          .and not_output.to_stderr
      end
    end

    context 'and is configured' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'coverage/.resultset.json',
          test_command: 'COVERAGE=1 rspec',
          debug: true
        )
        File.utime(Time.now, Time.now, 'coverage/.resultset.json')
      end

      it 'returns files' do
        expect do
          expect(simplecov_files).to include('lib/project.rb')
        end
          .to not_output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
          .and output(/{changed_trigger_files: \[\]}/).to_stderr
      end

      context 'and is outdated by code file' do
        before { File.utime(Time.now, Time.now, 'lib/project.rb') }

        it 'runs rspec and returns files' do
          expect do
            expect(simplecov_files).to include('lib/project.rb')
          end
            .to output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
            .and output(%r({changed_trigger_files: \["lib/project.rb"\]})).to_stderr
        end
      end

      context 'and is outdated by test file' do
        before { File.utime(Time.now, Time.now, 'spec/lib/project_spec.rb') }

        it 'runs rspec and returns files' do
          expect do
            expect(simplecov_files).to include('lib/project.rb')
          end
            .to output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
            .and output(%r({changed_trigger_files: \["spec/lib/project_spec.rb"\]})).to_stderr
        end
      end
    end
  end
end
