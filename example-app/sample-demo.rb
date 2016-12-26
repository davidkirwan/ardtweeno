$stdout.sync = true
####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Sample App which consumes the Ardtweeno API and provides some sample functionality
#
# @date         2014-08-06
####################################################################################################
##### Require statements
require 'rubygems'
require 'sinatra/base'
require 'ardtweeno'
require 'logger'
require 'date'
require 'typhoeus'
require File.join(File.dirname(__FILE__), '/settings-helper.rb')
require File.join(File.dirname(__FILE__), '/exceptions.rb')
require File.join(File.dirname(__FILE__), '/utility.rb')


module Example
class App < Sinatra::Base


  ##### Variables
  enable :static, :sessions, :logging
  set :environment, :production
  set :root, File.dirname(__FILE__)
  set :public_folder, File.join(root, '/public')
  set :views, File.join(root, '/views')
  
    
  # Create the logger instance
  set :log, Logger.new(STDOUT)
  set :level, Logger::DEBUG
  #set :level, Logger::INFO
  #set :level, Logger::WARN
  
  # Options hash
  set :options, {:log => settings.log, :level => settings.level}
  
  # Date
  today = DateTime.now
  theDate = today.year.to_s() + "-" + "%02d" % today.month.to_s() + "-" + "%02d" % today.day.to_s()
  set :date, theDate
  
  # Read in the configuration settings for the tech-demo web app see config.yaml
  @confdata = SampleDemo::ConfigReader.load(File.join(File.dirname(__FILE__), '/settings.yaml'), 
                                            settings.options)
  
  # URI to the ardtweeno gateway
  set :gateway, @confdata["gateway"]["url"]
  set :port, @confdata["gateway"]["port"]
  set :key, @confdata["gateway"]["key"]
  
#########################################################################################################



  not_found do
    erb :raise404, :layout => :main_layout, :locals => {:active=>0}
  end
  
  
  
  get '/' do   
    begin
      response = Example::Utility.root(settings.gateway, settings.port, settings.key)
      
      erb :index, 
          :layout => :main_layout, 
          :locals => {:running=>response[:status]["running"],
                      :packets=>response[:packets],
                      :zones=>response[:zones],
                      :active=>0}
      
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout, :locals => {:active=>0}
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout, :locals => {:active=>0}
    end
  end

  
  
  get '/controlpanel' do
    begin
      response = Example::Utility.controlpanel(settings.gateway, settings.port, settings.key)
      
      erb :controlpanel, :layout => :main_layout, :locals => {:nodeList=>response[:nodes], 
                                                              :watchList=>response[:watchList],
                                                              :active=>1}
      
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout, :locals => {:active=>0}
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout, :locals => {:active=>0}
    end
  end
  
  
  
  post '/gateway/start' do
    begin
      response = Example::Utility.gatewaystart(settings.gateway, settings.port, settings.key)
      return response
    
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout, :locals => {:active=>0}
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout, :locals => {:active=>0}
    end
  end



  post '/gateway/stop' do
    begin
      response = Example::Utility.gatewaystop(settings.gateway, settings.port, settings.key)
      return response
    
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout, :locals => {:active=>0}
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout, :locals => {:active=>0}
    end
  end
  
  
  
  post '/gateway/config' do
    begin
      response = Example::Utility.gatewayconfig(settings.gateway, settings.port, settings.key)
      return response
    
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout, :locals => {:active=>0}
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout, :locals => {:active=>0}
    end
  end

  
  
  post '/gateway/watch/:node' do |node|
    begin
      response = Example::Utility.addwatch(settings.gateway, settings.port, settings.key, node)
      return response
      
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout, :locals => {:active=>0}
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout, :locals => {:active=>0}
    end
  end
  
  
  
  get '/push/:node' do |node|
    `espeak "Movement detected on #{node}"`
  end

  

end # End of the App class
end # End of the Example module
