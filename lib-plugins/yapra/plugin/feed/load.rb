require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Feed
  # = Load RSS from given URLs
  # 
  # Load RSS from given URLs.
  # If URL is an Array, all URLs in the array will be loaded.
  # 
  #     - module: RSS::load
  #       config:
  #         url: http://www.example.com/hoge.rdf
  #
  class Load < Yapra::Plugin::MechanizeBase
    def run(data)
      urls = 
        if config['url'].kind_of?(Array)
          config['url']
        else
          [ config['url'] ]
        end
      
      urls.each do |url|
        data << extract_feed_from( url )
      end
      
      data
    end
  end
end
