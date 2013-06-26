$stdout.sync = true
####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Sample App built on top of the Ardtweeno API
#
# @date         26-06-2013
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


module SampleDemo
class SampleApp < Sinatra::Base


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

    
  get '/' do    
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    begin
      response = Typhoeus::Request.get("http://#{settings.gateway}:#{settings.port}/api/v1/system/status", 
					:body=> {:key => key}).body

      response = JSON.parse(response)

    rescue
      throw :halt, [ 503, "503 Service Currently Unavailable" ]
    end
    
    erb :gateway, :locals => {:running=>response["running"]}
    erb :index
  end
  
  
  get '/push/:node' do |node|
    `espeak "Movement detected on #{node}"`
  end
  
  end
  

end # End of the SampleApp class
end # End of the SampleDemo module
