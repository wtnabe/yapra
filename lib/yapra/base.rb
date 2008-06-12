# Base class of Yet Another Pragger implementation.
#
# This is initialized with hashed config string, and run pipeline.
#
# == Usage
#
#    Yapra::Base.new(config).execute()
#
# == Config Examples
# 
# === Format 1: Pragger like.
# A simplest. You can run one pipeline without global config.
#
#    - module: Module:name
#      config:
#        a: 3
#    - module: Module:name2
#      config:
#        a: b
#    - module: Module:name3
#      config:
#        a: 88
#
# === Format 2: Python habu like.
# You can run a lot of pipelines with global config.
#
#   global:
#     log:
#       out: stderr
#       level: warn
#
#   pipeline:
#     pipeline1:
#       - module: Module:name
#         config:
#           a: 3
#       - module: Module:name2
#         config:
#           a: b
#
#     pipeline2:
#       - module: Module:name
#         config:
#           a: 3
#       - module: Module:name2
#         config:
#           a: b
#
# === Format 3: Mixed type.
# You can run sigle pipeline with global config.
#
#   global:
#     log:
#       out: stderr
#       level: warn
#
#   pipeline:
#     - module: Module:name
#       config:
#         a: 3
#     - module: Module:name2
#       config:
#         a: b
#
require 'logger'
require 'yapra'
require 'yapra/inflector'
require 'yapra/legacy_plugin'

class Yapra::Base
  UPPER_CASE = /[A-Z]/
  
  attr_accessor :logger
  attr_reader :env
  attr_reader :pipelines
  
  def initialize global_config
    if global_config.kind_of?(Hash)
      @env = global_config['global'] || {}
      if global_config['pipeline']
        if global_config['pipeline'].kind_of?(Hash)
          @pipelines = global_config['pipeline']
        elsif global_config['pipeline'].kind_of?(Array)
          @pipelines = { 'default' => global_config['pipeline'] }
        end
      end
      raise 'config["global"]["pipeline"] is invalid!' unless @pipelines
    elsif global_config.kind_of?(Array)
      @env        = {}
      @pipelines  = { 'default' => global_config }
    else
      raise 'config file is invalid!'
    end
    
    create_logger
  end
  
  def execute
    self.pipelines.each do |k, v|
      self.logger.info("# pipeline '#{k}' is started...")
      execute_plugins v, []
    end
  end
  
  def execute_plugins command_array, data=[]
    command_array.inject(data) do |data, command|
      self.logger.info("exec plugin #{command["module"]}")
      execute_plugin(command, data.clone)
    end
  end
  
  def execute_plugin command, data=[]
    if class_based_plugin?(command['module'])
      run_class_based_plugin command, data
    else
      run_legacy_plugin command, data
    end
  end
  
  protected
  def class_based_plugin? command_name
    UPPER_CASE =~ command_name.split('::').last[0, 1]
  end
  
  def run_class_based_plugin command, data
    self.logger.debug("evaluate plugin as class based")
    require Yapra::Inflector.underscore(command['module'])
    plugin              = Yapra::Inflector.constantize("#{command['module']}").new
    plugin.yapra        = self if plugin.respond_to?('yapra=')
    plugin.execute(command, data)
  end
  
  def run_legacy_plugin command, data
    self.logger.debug("evaluate plugin as legacy")
    Yapra::LegacyPlugin.new(self, command['module']).run(command['config'], data)
  end
  
  def create_logger
    if env['log'] && env['log']['out']
      if env['log']['out'].index('file://')
        self.logger = Logger.new(URI.parse(env['log']['out']).path)
      else
        self.logger = Logger.new(Yapra::Inflector.constantize(env['log']['out'].upcase))
      end
    else
      self.logger = Logger.new(STDOUT)
    end
    
    if env['log'] && env['log']['level']
      self.logger.level = Yapra::Inflector.constantize("Logger::#{env['log']['level'].upcase}")
    end
  end
end