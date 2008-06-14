## Config::BasicAuth -- Yuanying
##
## post to web page with WWW::Mechanize agent.
## 
## - module: Config::BasicAuth
##   config:
##     user: yuanying
##     password: password-dayo
##
require 'yapra/plugin/mechanize_base'

module Yapra::Plugin::Config
  class BasicAuth < Yapra::Plugin::MechanizeBase
    def run(data)
      agent.basic_auth(config['user'], config['password'])
      data
    end
  end
end