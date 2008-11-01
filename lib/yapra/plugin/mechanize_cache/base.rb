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

  def get(options, parameters = [], referer = nil)
    if options.class != Hash
      options = {:url => options}
    end
    if referer.nil?
      referer = options[:url]
    end

    _get_(options, parameters, referer)
  end
end
