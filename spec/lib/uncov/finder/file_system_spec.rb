# frozen_string_literal: true

RSpec.describe Uncov::Finder::FileSystem, branch: 'develop' do
  subject { described_class.new.files }

  it { is_expected.to include('lib/project.rb') }
end
