# frozen_string_literal: true

RSpec.describe Uncov::Report do
  subject(:report) { described_class.new(files) }

  context 'when files are empty' do
    let(:files) { [] }

    it { is_expected.to have_attributes(coverage: 100.0, display?: false, display_files: [], trigger?: false) }
  end

  context 'when file lines not relevant' do
    let(:files) do
      [
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [
            Uncov::Report::File::Line.new(number: 1, simplecov: nil, nocov: nil, context: nil, git_diff: true, content: '')
          ]
        )
      ]
    end

    it { is_expected.to have_attributes(coverage: 100.0, display?: false, display_files: [], trigger?: false) }
  end

  context 'when all file lines covered' do
    let(:files) do
      [
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [
            Uncov::Report::File::Line.new(number: 1, simplecov: true, nocov: nil, context: nil, git_diff: true, content: 'puts "Hello world"')
          ]
        )
      ]
    end

    it { is_expected.to have_attributes(coverage: 100.0, display?: false, display_files: [], trigger?: false) }
  end

  context 'when no file lines covered' do
    let(:files) do
      [
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [
            Uncov::Report::File::Line.new(number: 1, simplecov: false, nocov: nil, context: nil, git_diff: true, content: 'puts "Hello world"')
          ]
        )
      ]
    end

    it { is_expected.to have_attributes(coverage: 0.0, display?: true, display_files: files, trigger?: true) }
  end

  context 'when all file lines nocov' do
    let(:files) do
      [
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [
            Uncov::Report::File::Line.new(number: 1, simplecov: nil, nocov: true, context: nil, git_diff: true, content: ':nocov:'),
            Uncov::Report::File::Line.new(number: 2, simplecov: nocov_covered, nocov: true, context: nil, git_diff: true, content: 'puts "nocov"'),
            Uncov::Report::File::Line.new(number: 3, simplecov: nil, nocov: true, context: nil, git_diff: true, content: ':nocov:')
          ]
        )
      ]
    end

    context 'when nocov not covered' do
      let(:nocov_covered) { false }

      it { is_expected.to have_attributes(coverage: 100.0, display?: false, display_files: [], trigger?: false) }
    end

    context 'when nocov covered' do
      let(:nocov_covered) { true }

      it { is_expected.to have_attributes(coverage: 100.0, display?: false, display_files: [], trigger?: false) }

      context 'with nocov_covered' do
        before { allow(Uncov.configuration).to receive(:nocov_covered).and_return(true) }

        it do
          is_expected.to have_attributes(
            coverage: 0.0,
            display?: true,
            display_files: [have_attributes(display_lines: [have_attributes(number: 2, nocov_covered?: true, relevant?: true)])],
            trigger?: true
          )
        end
      end
    end
  end

  context 'when some file lines covered and nocov' do
    let(:files) do
      [
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [
            Uncov::Report::File::Line.new(number: 1, simplecov: nil, nocov: true, context: nil, git_diff: true, content: ':nocov:'),
            Uncov::Report::File::Line.new(number: 2, simplecov: false, nocov: true, context: nil, git_diff: true, content: 'puts "nocov"'),
            Uncov::Report::File::Line.new(number: 3, simplecov: nil, nocov: true, context: nil, git_diff: true, content: ':nocov:'),
            Uncov::Report::File::Line.new(number: 4, simplecov: nil, nocov: nil, context: nil, git_diff: true, content: ''),
            Uncov::Report::File::Line.new(number: 5, simplecov: true, nocov: nil, context: nil, git_diff: true, content: 'puts "Covered one"'),
            Uncov::Report::File::Line.new(number: 6, simplecov: nil, nocov: nil, context: true, git_diff: true, content: ''),
            Uncov::Report::File::Line.new(number: 7, simplecov: false, nocov: nil, context: nil, git_diff: true, content: 'puts "Not covered"'),
            Uncov::Report::File::Line.new(number: 8, simplecov: nil, nocov: nil, context: true, git_diff: true, content: ''),
            Uncov::Report::File::Line.new(number: 9, simplecov: true, nocov: nil, context: nil, git_diff: true, content: 'puts "Covered two"')
          ]
        )
      ]
    end

    it { is_expected.to have_attributes(coverage: 66.67, display?: true, display_files: files, trigger?: true) }
  end

  context 'when some files lines covered' do
    let(:files) do
      [
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [Uncov::Report::File::Line.new(number: 1, simplecov: nil, nocov: nil, context: nil, git_diff: true, content: '')]
        ),
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [
            Uncov::Report::File::Line.new(number: 1, simplecov: true, nocov: nil, context: nil, git_diff: true, content: 'puts "Covered"')
          ]
        ),
        Uncov::Report::File.new(
          file_name: 'example.rb',
          git: true,
          lines: [
            Uncov::Report::File::Line.new(number: 1, simplecov: false, nocov: nil, context: nil, git_diff: true, content: 'puts "Not covered"')
          ]
        )
      ]
    end

    it { is_expected.to have_attributes(coverage: 50.0, display?: true, display_files: [files.last], trigger?: true) }
  end
end
