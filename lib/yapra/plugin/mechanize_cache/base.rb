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

class WWW::Mechanize
  alias_method :_get_, :get

  def get(url)
    _get_(url, nil, url)
  end
end
