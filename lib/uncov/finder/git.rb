# frozen_string_literal: true

require_relative 'git_base'

# collect list of files stored in git
module Uncov::Finder::Git
  class << self
    include Uncov::Finder::GitBase

    def files
      open_repo.ls_files.keys.filter_map do |file_name|
        [file_name, true] if relevant_file?(file_name)
      end.to_h
    end
  end
end
