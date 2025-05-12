# frozen_string_literal: true

RSpec.describe Uncov::Finder::FileSystem, branch: 'develop' do
  subject { described_class.new.code_files }

  it do
    is_expected.to eq(
      'lib/project.rb' => {
        1 => '# :nocov:',
        2 => 'def inc(a)',
        3 => '  a + 1',
        4 => 'end',
        5 => '',
        6 => 'def prec(str)',
        7 => "  return 'a' if str == 'b'",
        8 => '',
        9 => "  'b'",
        10 => 'end',
        11 => '# :nocov:',
        12 => '',
        13 => 'def dec(a)',
        14 => '  1',
        15 => 'end'
      }
    )
  end
end
