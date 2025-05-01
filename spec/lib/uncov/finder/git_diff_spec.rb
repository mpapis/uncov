# frozen_string_literal: true

RSpec.describe Uncov::Finder::GitDiff do
  subject(:git_diff_files) { described_class.files }

  context 'when unknown output_format' do
    before { allow(Uncov.configuration).to receive(:git_diff_target).and_return('sdkjfmdkfkdsjnvkjddfkkjdfnndfjkj') }

    it do
      expect { git_diff_files }.to raise_error(
        Uncov::NotGitBranchError, 'Target branch "sdkjfmdkfkdsjnvkjddfkkjdfnndfjkj" not found locally or in remote'
      )
    end
  end
end
