require 'mechanize'
require 'kconv'
require 'yapra/plugin/base'

class Yapra::Plugin::MechanizeBase < Yapra::Plugin::Base
  def agent
    if ( !pipeline.context['mechanize_agent'] )
      pipeline.context['mechanize_agent'] = WWW::Mechanize.new
      if config.has_key?('cache')
        init_cache(config['cache'])
      end
    end
    pipeline.context['mechanize_agent']
  end
  
  def extract_attribute_from element, item
    if plugin_config['extract_xpath']
      plugin_config['extract_xpath'].each do |k, v|
        value = nil
        case v.class.to_s
        when 'String'
          value = element.search(v).to_html.toutf8
        when 'Hash'
          ele = element.at( v['first_node'] )
          value = ( ele.nil? ) ? nil : ele.get_attribute( v['attr'] )
        end
        set_attribute_to item, k, value
      end
    end

    if plugin_config['apply_template_after_extracted']
      plugin_config['apply_template_after_extracted'].each do |k, template|
        value = apply_template template, binding
        set_attribute_to item, k, value
      end
    end
  end
    
  protected
  #
  # ex)
  #
  # config:
  #   method: pstore
  #   max_history: 30
  #
  def init_cache(opt)
    require File.join(File.dirname(File.expand_path(__FILE__)),
                                   'mechanize_cache',
                                   opt['method'])
    name = Object.module_eval("Yapra::Plugin::MechanizeCache::#{opt['method'].capitalize}")

    m = pipeline.context['mechanize_agent']
    cache = name.new(opt)

    m.max_history = opt['max_history'].to_i || 30
    cache.load_history.each { |h|
      m.history << h
    }
    m.history_added = Proc.new {
      cache.save_history(m.history)
    }
  end
end
