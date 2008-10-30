require 'yapra/plugin/base'

module Yapra::Plugin::MechanizeCache
  #
  # ex)
  #
  # - module: Feed::Load
  #   config:
  #     url: http://HOST/PATH
  #     cache: <--
  #       method: pstore
  #       path: /path/to/file
  #
  class Base < Yapra::Plugin::Base
  end
end
