# frozen_string_literal: true

RSpec.describe Uncov::Report do
  subject { described_class.new(files) }

  describe '#coverage' do
    subject { super().coverage }

    context 'when files are empty' do
      let(:files) { [] }

      it { is_expected.to eq(100.0) }
    end

    context 'when file lines not relevant' do
      let(:files) do
        [
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 1, simple_cov: nil, no_cov: nil, context: nil, git_diff: true, content: '')
            ]
          )
        ]
      end

      it { is_expected.to eq(100.0) }
    end

    context 'when all file lines covered' do
      let(:files) do
        [
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 1, simple_cov: true, no_cov: nil, context: nil, git_diff: true, content: 'puts "Hello world"')
            ]
          )
        ]
      end

      it { is_expected.to eq(100.0) }
    end

    context 'when no file lines covered' do
      let(:files) do
        [
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 1, simple_cov: false, no_cov: nil, context: nil, git_diff: true, content: 'puts "Hello world"')
            ]
          )
        ]
      end

      it { is_expected.to eq(0.0) }
    end

    context 'when all file lines nocov' do
      let(:files) do
        [
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 1, simple_cov: nil, no_cov: true, context: nil, git_diff: true, content: ':nocov:'),
              Uncov::Report::File::Line.new(number: 2, simple_cov: false, no_cov: true, context: nil, git_diff: true, content: 'puts "Hello one"'),
              Uncov::Report::File::Line.new(number: 3, simple_cov: nil, no_cov: true, context: nil, git_diff: true, content: ':nocov:')
            ]
          )
        ]
      end

      it { is_expected.to eq(100.0) }
    end

    context 'when some file lines covered and nocov' do
      let(:files) do
        [
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 1, simple_cov: nil, no_cov: true, context: nil, git_diff: true, content: ':nocov:'),
              Uncov::Report::File::Line.new(number: 2, simple_cov: false, no_cov: true, context: nil, git_diff: true, content: 'puts "Hello one"'),
              Uncov::Report::File::Line.new(number: 3, simple_cov: nil, no_cov: true, context: nil, git_diff: true, content: ':nocov:'),
              Uncov::Report::File::Line.new(number: 4, simple_cov: nil, no_cov: nil, context: nil, git_diff: true, content: ''),
              Uncov::Report::File::Line.new(number: 5, simple_cov: true, no_cov: nil, context: nil, git_diff: true, content: 'puts "Hello two"'),
              Uncov::Report::File::Line.new(number: 6, simple_cov: nil, no_cov: nil, context: true, git_diff: true, content: ''),
              Uncov::Report::File::Line.new(number: 7, simple_cov: false, no_cov: nil, context: nil, git_diff: true, content: 'puts "Hello three"'),
              Uncov::Report::File::Line.new(number: 8, simple_cov: nil, no_cov: nil, context: true, git_diff: true, content: ''),
              Uncov::Report::File::Line.new(number: 9, simple_cov: true, no_cov: nil, context: nil, git_diff: true, content: 'puts "Hello world"')
            ]
          )
        ]
      end

      it { is_expected.to eq(66.67) }
    end

    context 'when some files lines covered' do
      let(:files) do
        [
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [Uncov::Report::File::Line.new(number: 1, simple_cov: nil, no_cov: nil, context: nil, git_diff: true, content: '')]
          ),
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 1, simple_cov: true, no_cov: nil, context: nil, git_diff: true, content: 'puts "Hello world"')
            ]
          ),
          Uncov::Report::File.new(
            file_name: 'example.rb',
            git: true,
            lines: [
              Uncov::Report::File::Line.new(number: 1, simple_cov: false, no_cov: nil, context: nil, git_diff: true, content: 'puts "Hello world"')
            ]
          )
        ]
      end

      it { is_expected.to eq(66.67) }
    end
  end
end
