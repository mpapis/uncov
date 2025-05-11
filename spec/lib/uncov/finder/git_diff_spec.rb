# frozen_string_literal: true

RSpec.describe Uncov::Finder::GitDiff do
  subject(:git_diff) { described_class.new }

  before { allow(Uncov.configuration).to receive(:target).and_return(target) }

  describe '#code_files' do
    subject(:git_diff_code_files) { git_diff.code_files }

    context 'when comparing with HEAD', branch: 'test' do
      let(:target) { 'HEAD' }

      before { File.write('lib/project.rb', "def neg(a)\n  false\nend\n", mode: 'a') }

      it { is_expected.to eq('lib/project.rb' => { 14 => nil, 15 => nil, 16 => nil }) }
    end

    context 'when comparing with tag v1', branch: 'test' do
      let(:target) { 'v1' }

      before { File.write('lib/project.rb', "def neg(a)\n  false\nend\n", mode: 'a') }

      it { is_expected.to eq('lib/project.rb' => { 14 => nil, 15 => nil, 16 => nil }) }
    end

    context 'when comparing with HEAD^', branch: 'test' do
      let(:target) { 'HEAD^' }

      before { File.write('lib/project.rb', "def neg(a)\n  false\nend\n", mode: 'a') }

      it { is_expected.to eq('lib/project.rb' => { 14 => nil, 15 => nil, 16 => nil }) }
    end

    context 'when comparing with branch', branch: 'develop' do
      let(:target) { 'clean' }

      it { is_expected.to eq('lib/project.rb' => { 6 => nil, 7 => nil, 8 => nil, 9 => nil }) }
    end

    context 'when comparing with unknown target', branch: 'test' do
      let(:target) { 'unknown' }

      it do
        expect { git_diff_code_files }.to raise_error(
          Uncov::NotGitObjectError, 'Git target "unknown" not found locally'
        )
      end
    end
  end
end
