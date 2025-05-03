# frozen_string_literal: true

RSpec.describe Uncov::Finder::SimpleCov do
  subject(:simplecov_files) { described_class.files(trigger_files) }

  before { allow(Uncov.configuration).to receive(:target).and_return('clean') }

  let(:trigger_files) { %w[lib/project.rb] }

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
          .and raise_error(Uncov::MissingSimpleCovReport, 'SimpleCov results not found at "coverage/coverage.json"')
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
          .and raise_error(Uncov::AutodetectSimpleCovPathError, 'Could not autodetect coverage report path')
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
    context 'and is autodetected', branch: 'test_coverage_resultset' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'autodetect',
          test_command: 'COVERAGE=1 rspec'
        )
      end

      it 'returns files' do
        expect do
          expect(simplecov_files).to include('lib/project.rb')
        end
          .to not_output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
      end
    end

    context 'and is configured', branch: 'test_coverage_resultset' do
      before do
        allow(Uncov.configuration).to receive_messages(
          simplecov_file: 'coverage/.resultset.json',
          test_command: 'COVERAGE=1 rspec'
        )
      end

      it 'returns files' do
        expect do
          expect(simplecov_files).to include('lib/project.rb')
        end
          .to not_output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
      end

      context 'and is outdated' do
        before { File.utime(Time.now, Time.now, 'lib/project.rb') }

        it 'runs rspec and returns files' do
          expect do
            expect(simplecov_files).to include('lib/project.rb')
          end
            .to output(%r{^Coverage report generated for RSpec .*spec/fixtures/project/coverage}).to_stdout_from_any_process
        end
      end
    end
  end
end
