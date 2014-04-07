$stdout.sync = true
####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  Ardtweeno Application Gateway HTTP REST API Sinatra Web App
#
# @date         14-06-2013
####################################################################################################
##### Require statements
require 'rubygems'
require 'sinatra/base'
require 'ardtweeno'
require 'logger'


class RESTAPI < Sinatra::Base

  ##### Sinatra Variables
  enable :static, :sessions, :logging
  set :root, File.join(File.dirname(__FILE__) + '/../../')
  set :public_folder, File.join(root, '/public')
  set :views, File.join(root, '/views')
  
  #############################################################################################
    
  # Create the logger instance
  set :log, Logger.new(STDOUT)
  set :level, Logger::DEBUG
  #set :level, Logger::INFO
  #set :level, Logger::WARN
  
  # Options hash
  unless ENV['RACK_ENV'] == 'test'
    set :environment, :production
    set :options, {:log => settings.log, :level => settings.level}
  else
    set :environment, :test
    @confdata = {"dev"=>"/dev/pts/2",
                  "speed"=>9600,
                  "newsURI"=>"b97cb9ae44747ee263363463b7e56",
                  "adminkey"=>"1230aea77d7bd38898fec74a75a87738dea9f657",
                  "db"=>{"dbHost"=>"localhost",
                         "dbPort"=>27017,
                         "dbUser"=>"david",
                         "dbPass"=>"86ddd1420701a08d4a4380ca5d240ba7",
                         "dbName"=>"ardtweeno",
                         "dbPacketsColl"=>"packets"
                         },
                  "zones"=>[{"zonename"=>"testzone0",
                             "zonekey"=>"455a807bb34b1976bac820b07c263ee81bd267cc",
                             "zonenodes"=>["node0","node1"]
                             },
                             {"zonename"=>"testzone1",
                              "zonekey"=>"79a7c75758879243418fe2c87ec7d5d4e1451129",
                              "zonenodes"=>["node2","node3"]
                             }]
                  }
    
    set :options, {:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG, :confdata=>@confdata}
  end
  
  # Setup the system for use
  Ardtweeno.setup(settings.options)
  @@theDispatcher = Ardtweeno::Dispatcher.instance
  
  # Posts Array
  set :posts, @@theDispatcher.getPosts
  
  # Posts URI
  set :newsURI, @@theDispatcher.getPostsURI

    
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
    begin
      diskusage = @@theDispatcher.diskUsage
      
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
    
    erb :status, :locals => {:diskusage=>diskusage}
  end
  
  
  get '/topology' do
    settings.log.debug params.inspect
    
    begin
      theResponse = @@theDispatcher.constructTopology(params)
      
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
    
    erb :topology, :locals => {:theTopology=>theResponse}
  end
  
  
  get '/api' do
    erb :api
  end
  
  
  get '/graph/v1/punchcard/:node' do |node|
    begin
      theData, theDays, theRange= @@theDispatcher.constructPunchcard(params)
      
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end

    erb :punchcard, :locals => {:node=>params[:node], :ourGraphData=>theData, :ourGraphDays=>theDays, :ourGraphRange=>theRange}
  end
  
  
  get "/#{settings.newsURI}/create/post" do
    running = @@theDispatcher.running?
    erb :createpost, :locals => {:running => running}
  end
  
  
  post "/#{settings.newsURI}/create/post" do
    settings.log.debug params.inspect
    
    thePost = Hash.new
    
    unless params["title"].nil? then thePost[:posttitle] = params["title"]; end
    unless params["content"].nil? then thePost[:postcontent] = params["content"]; end
    unless params["code"].nil? then thePost[:postcode] = params["code"]; end 
    
    unless params["posts"].nil? then
      if params["posts"] == 'makepost'
        settings.posts << thePost

        @@theDispatcher.savePosts(settings.posts)
      end
    end
    
    redirect '/'
  end
      
      
  not_found do
    '404 Page Not Found'
  end
  
  
#########################################################################################################
  

  get '/api/v1/zones' do
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    settings.log.debug "The retrieve zones hook has been called"

    unless zonedata.nil?
      params["role"] = zonedata[:role]
      unless params.has_key?("zonename") then params["zonename"] = zonedata["zonename"]; end
    end
    
    begin
      @@theDispatcher.retrieve_zones(params).to_json # Returns String in JSON form
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end
  
  
  get '/api/v1/zones/:zonename' do |zonename|
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    settings.log.debug "The retrieve zones hook has been called"

    unless zonedata.nil?
      params["role"] = zonedata[:role]
    end
    
    begin
      @@theDispatcher.retrieve_zones(params).to_json # Returns String in JSON form
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end
  
  
#########################################################################################################    

    
  get '/api/v1/packets' do
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    settings.log.debug "The retrieve packets hook has been called"
    
    begin
      @@theDispatcher.retrieve_packets(params).to_json # Returns String in JSON form
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end
  
    
  post '/api/v1/packets' do 
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
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
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    settings.log.debug "The retrieve nodes hook has been called"
    
    begin
      @@theDispatcher.retrieve_nodes(params).to_json # Returns String in JSON form
    rescue Exception => e
      raise e
      #throw :halt, [ 500, "500 Internal Server Error" ]
    end
  end


#########################################################################################################

  post '/api/v1/watch/:node' do |node|
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    settings.log.debug "The add watch to node hook has been called"
    
    begin
      @@theDispatcher.addWatch(params)
    rescue Exception => e
      throw :halt, [ 400, "400 Bad Request" ]
    end
  end
  
  
  get '/api/v1/watch/:node' do |node|
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    settings.log.debug "Check if a node is being watched"
    
    begin
      @@theDispatcher.watched?(params).to_json
    rescue Exception => e
      throw :halt, [ 400, "400 Bad Request" ]
    end
  end


  get '/api/v1/watch' do
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    settings.log.debug "Check if a node is being watched"
    
    begin
      @@theDispatcher.watchList.to_json
    rescue Exception => e
      raise e
      #throw :halt, [ 400, "400 Bad Request" ]
    end
  end

#########################################################################################################
  
  get '/api/v1/system/config' do
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    throw :halt, [ 401, "401 Not Authorised" ] unless zonedata[:role] == "admin"
    settings.log.debug "The system config hook has been called, querying the Ardtweeno gateway to retrieve config"
    
    begin
      return @@theDispatcher.config.to_json
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
    
  end
  
  
  get '/api/v1/system/start' do
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    throw :halt, [ 401, "401 Not Authorised" ] unless zonedata[:role] == "admin"
    settings.log.debug "The system start hook has been called, launching the Ardtweeno system"
      
    begin
      theResponse = @@theDispatcher.start
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end 
      
    return {:response=>theResponse, :running=>@@theDispatcher.running?}.to_json
  end
    
    
  get '/api/v1/system/stop' do
    auth, zonedata = @@theDispatcher.authenticate?(params[:key])
    throw :halt, [ 404, "404 Page Not Found" ] unless auth
    throw :halt, [ 401, "401 Not Authorised" ] unless zonedata[:role] == "admin"
    settings.log.debug "The system stop hook has been called, shutting the Ardtweeno system down..."
    
    begin
      theResponse = @@theDispatcher.stop
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
      
    return {:response=>theResponse, :running=>@@theDispatcher.running?}.to_json    
  end
  


  get '/api/v1/system/status' do
    settings.log.debug "The system status hook has been called, reading the host configuration"

    begin
      return @@theDispatcher.status?.to_json
      
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end

  end


  get '/api/v1/system/status/list' do
    settings.log.debug "The system status list hook has been called, returning the last 15 mins of status data"
    
    begin
      return {:buffer=>@@theDispatcher.statuslist}.to_json
      
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error"]
    end
  end

#########################################################################################################




# End of RESTAPI Class
end
