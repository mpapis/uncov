# frozen_string_literal: true

RSpec.describe Uncov::Finder::GitDiff do
  subject(:git_diff_files) { described_class.files }

  before { allow(Uncov.configuration).to receive(:target).and_return(target) }

  context 'when comparing with HEAD', :reset_git, branch: 'develop' do
    let(:target) { 'HEAD' }

    before do
      File.write('lib/example.rb', "true\n")
      system_run('git add lib/example.rb')
    end

    it { is_expected.to include('lib/example.rb') }
  end

  context 'when comparing with clean branch', branch: 'develop' do
    let(:target) { 'clean' }

    it { is_expected.to include('lib/project.rb') }
  end

  context 'when comparing with unknown target' do
    let(:target) { 'unknown' }

    it do
      expect { git_diff_files }.to raise_error(
        Uncov::NotGitBranchError, 'Target branch "unknown" not found locally or in remote'
      )
    end
  end
end
