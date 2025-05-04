# frozen_string_literal: true

RSpec.describe Uncov::Finder::GitDiff do
  subject(:git_diff_files) { described_class.files }

  before { allow(Uncov.configuration).to receive(:target).and_return(target) }

  context 'when comparing with HEAD', branch: 'test' do
    let(:target) { 'HEAD' }

    before { File.write('lib/project.rb', "def neg(a)\n  false\nend\n", mode: 'a') }

    it { is_expected.to eq('lib/project.rb' => { 10 => nil, 11 => nil, 12 => nil }) }
  end

  context 'when comparing with branch', branch: 'develop' do
    let(:target) { 'clean' }

    it { is_expected.to eq('lib/project.rb' => { 6 => nil, 7 => nil, 8 => nil, 9 => nil }) }
  end

  context 'when comparing with unknown target', branch: 'test' do
    let(:target) { 'unknown' }

    it do
      expect { git_diff_files }.to raise_error(
        Uncov::NotGitBranchError, 'Target branch "unknown" not found locally or in remote'
      )
    end
  end
end
