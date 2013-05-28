$stdout.sync = true
####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  Ardtweeno Application Gateway HTTP REST API Sinatra Web App
#
# @date         26-05-2013
####################################################################################################
##### Require statements
require 'rubygems'
require 'sinatra/base'
require 'ardtweeno'
require 'logger'
require 'rufus/scheduler'

class RESTAPI < Sinatra::Base

  ##### Variables
  enable :static, :sessions, :logging
  set :environment, :production
  set :root, File.join(File.dirname(__FILE__) + '/../../')
  set :public_folder, Proc.new {File.join(root, '/public')}
  set :views, Proc.new {File.join(root, '/views')}
  
  # Posts Array
  set :posts, Array.new
  thePosts = YAML.load(File.open('posts.yaml'))
  unless thePosts["posts"].nil? or thePosts["posts"].empty? then settings.posts = thePosts["posts"]; end
    
  # Create the logger instance
  set :log, Logger.new(STDOUT)
  set :level, Logger::DEBUG
  #set :level, Logger::INFO
  #set :level, Logger::WARN
  
  # Options hash
  set :options, {:log => settings.log, :level => settings.level}
  
  # Rufus-scheduler object
  set :scheduler, Rufus::Scheduler.start_new
  
  # Setup the system for use
  Ardtweeno.setup(settings.options)
  @@theDispatcher = Ardtweeno::Dispatcher.instance
  
#########################################################################################################  


  settings.scheduler.every '60m' do
      
    begin
      settings.log.debug "Running scheduled data flush"
      @@theDispatcher.flush()
                        
    rescue Ardtweeno::DBError => e
      settings.log.warn "ERROR: #{e.message}"
    end
     
  end

    
#########################################################################################################

    
  get '/' do
    running = @@theDispatcher.running?

    erb :index, :locals => {:running => running}
  end
  
    
  get '/home' do
    theposts = settings.posts

    if theposts.length >= 5
      theposts = theposts[(theposts.length - 5), theposts.length]
    end

    erb :home, :locals => {:postdata => theposts.reverse}
  end
  
  
  get '/status' do
    erb :status
  end
  
  
  get '/b97cb9ae44747ee263363463b7e56/create/post' do
    running = @@theDispatcher.running?
    erb :createpost, :locals => {:running => running}
  end
  
  
  post '/b97cb9ae44747ee263363463b7e56/create/post' do
    settings.log.debug params.inspect
    
    thePost = Hash.new
    
    unless params["title"].nil? then thePost[:posttitle] = params["title"]; end
    unless params["content"].nil? then thePost[:postcontent] = params["content"]; end
    unless params["code"].nil? then thePost[:postcode] = params["code"]; end 
    
    unless params["posts"].nil? then
      if params["posts"] == 'makepost'
        settings.posts << thePost

        f = File.open("posts.yaml", "w")
        f.write({"posts"=>settings.posts}.to_yaml)
        f.close
      end
    end
    
    redirect '/'
  end
      
      
  not_found do
    '404 Page Not Found'
  end
  
  
#########################################################################################################
  

  get '/api/v1/zones' do
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The retrieve zones hook has been called"
    
    begin
      @@theDispatcher.retrieve_zones(params).to_json # Returns String in JSON form
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end
  
  
  get '/api/v1/zones/:zonename' do |zoneid|
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The retrieve zones hook has been called"
    
    begin
      @@theDispatcher.retrieve_zones(params).to_json # Returns String in JSON form
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end
  
  
#########################################################################################################    

    
  get '/api/v1/packets' do
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The retrieve packets hook has been called"
    
    begin
      @@theDispatcher.retrieve_packets(params).to_json # Returns String in JSON form
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end
  
    
  post '/api/v1/packets' do 
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The add packets hook has been called"
      
    settings.log.debug "Add packet API request: " + params[:payload]
    begin
      @@theDispatcher.store(params[:payload])
        
    rescue Ardtweeno::NodeNotAuthorised => e
      throw :halt, [ 401, "401 Unauthorised" ]
    rescue Exception => e
      throw :halt, [ 400, "400 Bad Request" ]
    end
  end
    

#########################################################################################################

  get '/api/v1/nodes' do
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The retrieve nodes hook has been called"
    
    begin
      @@theDispatcher.retrieve_nodes(params).to_json # Returns String in JSON form
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end


#########################################################################################################

  post '/api/v1/watch/:node' do |node|
    settings.log.debug params.inspect
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The add watch to node hook has been called"
    
    begin
      @@theDispatcher.addWatch(params)
    rescue Exception => e
      throw :halt, [ 400, "400 Bad Request" ]
    end
    
  end


#########################################################################################################
  
  get '/api/v1/system/config' do
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The system config hook has been called, querying the Ardtweeno gateway to retrieve config"
    
    begin
      return @@theDispatcher.config.to_json
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
    
  end
  
  
  get '/api/v1/system/start' do
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The system start hook has been called, launching the Ardtweeno system"
      
    begin
      @@theDispatcher.start
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end 
      
    "The Ardtweeno system is launching, this will take a moment..."
  end
    
    
  get '/api/v1/system/stop' do
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The system stop hook has been called, shutting the Ardtweeno system down..."
    
    begin
      @@theDispatcher.stop
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
      
    "The Ardtweeno system is shutting down, this will take a moment..."    
  end
  
  
  # This is currently not implemented correctly  
  get '/api/v1/system/reboot' do
    throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The system reboot hook has been called, rebooting the host"
      
    begin
      @@theDispatcher.reboot
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
    
    "The host is rebooting, this will take a moment..."
  end


  get '/api/v1/system/status' do
    # Considering making this api target public to avoid having to store API keys in the highcarts.js
    # graphs..
    #throw :halt, [ 404, "404 Page Not Found" ] unless @@theDispatcher.authenticate?(params[:key])
    settings.log.debug "The system status hook has been called, reading the host configuration"

    begin
      return @@theDispatcher.status?().to_json
      
    rescue Exception => e
      raise e
      #throw :halt, [ 500, "500 Internal Server Error" ]
    end

  end

#########################################################################################################

# End of RESTAPI Class
end
