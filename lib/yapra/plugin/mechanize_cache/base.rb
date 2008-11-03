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
    def max_history=(num)
      @max_history = num
    end

    def max_history
      @max_history
    end

    def update_only=(bool)
      @update_only = bool
    end

    def update_only
      @update_only || false
    end

    def not_modified=(bool)
      @not_modified = bool
    end

    def not_modified
      @not_modified || false
    end

    def updated_feed_items(url, curr)
      last_modified = nil
      past_props    = []

      load_feed(url).each { |item|
        hash = key_props(item)
        past_props << hash
        if last_modified.nil? or last_modified < hash['modified']
          last_modified = hash['modified']
        end
      }
      save_feed(url, curr)
      
      items = []
      curr.each { |item|
        hash = key_props(item)
        if ( (last_modified.nil? or hash['modified'] > last_modified) and
             !past_props.include?(hash) )
          items << item
        end
      }

      return items
    end

    protected
    def key_props(item)
      h = {}
      h['link']     = begin item.about rescue item.link end
      h['author']   = begin item.author rescue item.dc_creator end
      h['modified'] = begin item.pubDate rescue item.dc_date end
      h['content']  = begin
                        item.content
                      rescue
                        begin
                          item.content_encoded
                        rescue
                          item.description
                        end
                      end
      h['category'] = begin
                        item.category
                      rescue
                        a = []
                        begin
                          item.subject.each { |e|
                            a << e.content
                          }
                          a
                        rescue
                          []
                        end
                      end

      return h
    end
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
