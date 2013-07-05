$stdout.sync = true
####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Sample App which consumes the Ardtweeno API and provides some sample functionality
#
# @date         2013-07-04
####################################################################################################
##### Require statements
require 'rubygems'
require 'sinatra/base'
require 'ardtweeno'
require 'logger'
require 'rufus/scheduler'
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
    erb :raise404, :layout => :main_layout
  end
  
  
  
  get '/' do   
    begin
      response = Example::Utility.root(settings.gateway, settings.port, settings.key)
      
      erb :index, 
          :layout => :main_layout, 
          :locals => {:running=>response[:status]["running"],
                      :packets=>response[:packets],
                      :zones=>response[:zones]}
      
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout
    end
  end

  
  
  get '/controlpanel' do    
    erb :controlpanel, :layout => :main_layout
  end
  
  
  
  post '/gateway/start' do
    begin
      response = Example::Utility.gatewaystart(settings.gateway, settings.port, settings.key)
      # Return the response
      return response
    
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout
    end
  end



  post '/gateway/stop' do
    begin
      response = Example::Utility.gatewaystop(settings.gateway, settings.port, settings.key)
      # Return the response
      return response
    
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout
    end
  end
  
  
  
  post '/gateway/config' do
    begin
      response = Example::Utility.gatewayconfig(settings.gateway, settings.port, settings.key)
      # Return the response
      return response
    
    rescue Example::Error500 => e
      status 500
      erb :raise500, :layout => :main_layout
    rescue Example::Error503 => e
      status 503
      erb :raise503, :layout => :main_layout
    end
  end

  
  
  get '/push/:node' do |node|
    `espeak "Movement detected on #{node}"`
  end

  

end # End of the SampleApp class
end # End of the SampleDemo module
