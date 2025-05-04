# frozen_string_literal: true

RSpec.describe Uncov::Formatter do
  subject(:formatter_output) { described_class.output(report) }

  context 'when unknown output_format' do
    let(:report) { Uncov::Report.new(files: [Uncov::Report::File.new(lines: [Uncov::Report::File::Line.new(simple_cov: false)])]) }

    before { allow(Uncov.configuration).to receive(:output_format).and_return(:unknown) }

    it do
      expect { formatter_output }
        .to raise_error(Uncov::UnsupportedFormatterError, ':unknown is not a supported formatter')
        .and not_output.to_stdout_from_any_process
        .and not_output.to_stderr_from_any_process
    end
  end

  context 'when all covered' do
    let(:report) { Uncov::Report.new(files: [Uncov::Report::File.new(lines: [Uncov::Report::File::Line.new(simple_cov: true)])]) }

    before { allow(Uncov.configuration).to receive(:output_format).and_return(:unknown) }

    it do
      expect { formatter_output }
        .to output("\e[0;32;49mAll changed files(1) have 100% test coverage!\e[0m\n").to_stdout_from_any_process
        .and not_output.to_stderr_from_any_process
    end
  end

  context 'when no files' do
    let(:report) { Uncov::Report.new(files: []) }

    before { allow(Uncov.configuration).to receive(:output_format).and_return(:unknown) }

    it do
      expect { formatter_output }
        .to output("\e[0;32;49mNo files to report.\e[0m\n").to_stdout_from_any_process
        .and not_output.to_stderr_from_any_process
    end
  end
end
