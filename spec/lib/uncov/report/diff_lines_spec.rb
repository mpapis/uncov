# frozen_string_literal: true

RSpec.describe Uncov::Report::DiffLines do
  subject(:files) { described_class.files(finder) }

  let(:finder) { Uncov::Finder.new(:git_diff) }
  let(:context) { 1 }

  before { allow(Uncov.configuration).to receive_messages(target:, context:, simplecov_file: 'coverage/coverage.json') }

  context 'when no changes', branch: 'test_coverage_json' do
    let(:target) { 'develop' }

    it { is_expected.to be_empty }
  end

  context 'when changes', branch: 'develop_coverage_json' do
    let(:target) { 'clean' }

    it 'returns report file with lines of diff' do
      is_expected.to eq(
        [
          Uncov::Report::File.new(
            file_name: 'lib/project.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 6, simple_cov: nil, no_cov: nil, context: false, git_diff: true, content: ''),
              Uncov::Report::File::Line.new(number: 7, simple_cov: true, no_cov: nil, context: true, git_diff: true, content: 'def dec(a)'),
              Uncov::Report::File::Line.new(number: 8, simple_cov: false, no_cov: nil, context: false, git_diff: true, content: '  1'),
              Uncov::Report::File::Line.new(number: 9, simple_cov: nil, no_cov: nil, context: true, git_diff: true, content: 'end')
            ]
          )
        ]
      )
    end

    context 'with context: 3' do
      let(:context) { 3 }

      it 'returns report file with lines outside of diff' do
        is_expected.to eq(
          [
            Uncov::Report::File.new(
              file_name: 'lib/project.rb',
              git: true,
              lines: [
                Uncov::Report::File::Line.new(number: 5, simple_cov: nil, no_cov: true, context: true, git_diff: false, content: '# :nocov:'),
                Uncov::Report::File::Line.new(number: 6, simple_cov: nil, no_cov: nil, context: true, git_diff: true, content: ''),
                Uncov::Report::File::Line.new(number: 7, simple_cov: true, no_cov: nil, context: true, git_diff: true, content: 'def dec(a)'),
                Uncov::Report::File::Line.new(number: 8, simple_cov: false, no_cov: nil, context: false, git_diff: true, content: '  1'),
                Uncov::Report::File::Line.new(number: 9, simple_cov: nil, no_cov: nil, context: true, git_diff: true, content: 'end')
              ]
            )
          ]
        )
      end
    end
  end
end
