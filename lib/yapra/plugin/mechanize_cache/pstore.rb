require 'pstore'
require 'yaml'
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
      @dir = nil

      if config.has_key?('path')
        @dir     = config['path']
        @history = File.join(@dir, 'history')
        @feeds   = PStore.new(File.join(@dir, 'feeds'))
      end
    end

    def load_history
      history  = []

      if (File.exist?(@history) and File.size(@history) > 0)
        history = Marshal.load(open(@history))
      end

      return history
    end

    def save_history(history)
      Marshal.dump(history, open(@history, 'w'))
    end

    protected
    def load_feed(url)
      feed = []

      @feeds.transaction(true) { |db|
        if db.root?(url)
          feed = YAML.load(db[url])
        end
      }

      feed
    end

    def save_feed(url, feed)
      @feeds.transaction { |db|
        db[url] = YAML.dump(feed)
      }
    end
  end
end
