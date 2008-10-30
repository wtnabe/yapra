require 'pstore'
require File.join(File.dirname(File.expand_path(__FILE__)), 'base.rb')

module Yapra::Plugin::MechanizeCache
  #
  # config:
  #   url: http://HOST/PATH
  #   cache: 
  #     method: pstore
  #     path: /path/to/dir
  #
  class Pstore < Base
    def initialize(config)
      @path = nil

      if config.has_key?('path')
        @path = config['path']        
      end
    end

    def load_history
      path = File.join(@path, 'history')
      ret  = []

      if (File.exist?(path) and File.size(path) > 0)
        ret = Marshal.load(open(path))
      end

      return ret
    end

    def save_history(history)
      Marshal.dump(history, open(File.join(@path, 'history'), 'w'))
    end
  end
end
