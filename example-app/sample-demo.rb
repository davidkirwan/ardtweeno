$stdout.sync = true
####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Sample App built on top of the Ardtweeno API
#
# @date         29-06-2013
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
  
    
#########################################################################################################



  not_found do
    erb :raise404, :layout => :main_layout
  end
  
  
  
  get '/' do    
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    begin
      response = Example::Utility.root(key, settings.gateway, settings.port)
      
      erb :index, :layout => :main_layout, :locals => {:running=>response[:status]["running"],
                                                       :packets=>0,
                                                       :zones=>0
                                                      }
      
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
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    begin
      response = Example::Utility.gatewaystart(key, settings.gateway, settings.port)
            
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
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    begin
      response = Example::Utility.gatewaystop(key, settings.gateway, settings.port)
            
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
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    begin
      response = Typhoeus::Request.get("http://#{settings.gateway}:#{settings.port}/api/v1/system/config", 
          :body=> {:key => key})

      if response.options[:return_code] == :ok
        begin
          response = JSON.pretty_generate(JSON.parse(response.body))
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
      
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
