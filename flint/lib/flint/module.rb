require 'fastlane_core/helper'

module Flint
  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Easily sync your keystores across your team using git"

  def self.environments
    return %w(development release)
  end

  def self.cert_type_sym(type)
    return :development if type == "development"
    return :release if type == "release"
    raise "Unknown cert type: '#{type}'"
  end
end
