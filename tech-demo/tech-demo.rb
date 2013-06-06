$stdout.sync = true
####################################################################################################
# @author       David Kirwan 
# @description  Ardtweeno Application Gateway Tech Demo
#
# @date         25-02-2013
####################################################################################################
##### Require statements
require 'rubygems'
require 'sinatra/base'
require 'ardtweeno'
require 'logger'
require 'rufus/scheduler'
require 'date'
require 'typhoeus'
require File.join(File.dirname(__FILE__), '/configreader.rb')


class ArdtweenoDemo < Sinatra::Base

  attr_accessor :ardtweenouri

  ##### Variables
  enable :static, :sessions, :logging
  set :environment, :production
  set :root, File.dirname(__FILE__)
  set :public_folder, Proc.new {File.join(root, '/public')}
  set :views, Proc.new {File.join(root, '/views')}
  
    
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
  @confdata = Ardtweeno::ConfigReader.load(File.join(File.dirname(__FILE__), '/config.yaml'), 
                                            settings.options)
  
  # URI to the ardtweeno gateway
  set :ardtweenouri, @confdata["gateway"]["url"]
  set :ardtweenoport, @confdata["gateway"]["port"]
  
    
#########################################################################################################

    
  get '/' do    
    erb :index
  end
  
  
  get '/push/:node' do |node|
    `espeak "Movement detected on #{node}"`
  end
  
  get '/gateway' do    
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    begin
      response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/system/status", :body=> {:key => key}).body
      response = JSON.parse(response)
    rescue
      throw :halt, [ 503, "503 Service Currently Unavailable" ]
    end
    
    erb :gateway, :locals => {:running=>response["running"]}
  end
  
  post '/gateway' do
    response = makeCall(params)

    return response
  end
  
  post '/gateway/topology' do
    topology = constructTopology(params)
    response = topologyParser(topology)

    erb :topology, :locals => {:ourTopology =>  response}
  end
  
  post '/gateway/zones' do
    response = makeCallToZones(params)

    return response
  end
  
  post '/gateway/nodes' do
    response = makeCallToNodes(params)

    return response
  end
  
  post '/gateway/packets' do
    response = makeCallToPackets(params)

    return response
  end
  
  post '/contact' do
    erb :contact
  end
  
  get '/gateway/data/:node' do |node|
    begin
      theName, theTimes, theData = makeCallToData(params)
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end

    erb :sensorgraph, :locals => {:ourName=> theName, :ourGraphTimes => theTimes, :ourGraphData=> theData}
  end
  
  get '/gateway/stats' do
    begin
      theData = makeCallToZoneStats(params)
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end
    
    erb :zonestatistics, :locals=> {:ourGraphData=> theData}
  end
  
  get '/gateway/punchcard/:node' do |node|
    begin
      theData, theDays = constructPunchcardGraph(params)
    rescue Exception => e
      throw :halt, [ 500, "500 Internal Server Error" ]
    end

    erb :punchcard, :locals => {:node=>params[:node], :ourGraphData=>theData, :ourGraphDays=>theDays}
  end
  
  not_found do
    '404 Page Not Found'
  end
  
#########################################################################################################

  def makeCall(params)
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"

    begin
      if(params[:system] == "config")
        response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/system/config", :body=> {:key => key}).body
        settings.log.debug response
        
        response = JSON.pretty_generate(JSON.parse(response))
      elsif(params[:system] == "start")
        response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/system/start", :body=> {:key => key}).body
        settings.log.debug response
            
      elsif(params[:system] == "stop")
        response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/system/stop", :body=> {:key => key}).body
        settings.log.debug response
        
      elsif(params[:system] == "restart")
        response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/system/reboot", :body=> {:key => key}).body
        settings.log.debug response
        
      end

    rescue Exception => e
      settings.log.debug e
      return e
    end

    return response
  end

  
  def makeCallToZones(params)
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    begin
      response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/zones", :body=> {:key => key}).body
      settings.log.debug response
      
      response = JSON.pretty_generate(JSON.parse(response))
    
    rescue Exception => e
      settings.log.debug e
      return e
    end
    
    return response
  end


  def makeCallToNodes(params)
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    params[:key] = key

    begin
      response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/nodes", :body=> params).body
      settings.log.debug response
      
      unless params[:nopretty] then response = JSON.pretty_generate(JSON.parse(response)); end
    
    rescue Exception => e
      settings.log.debug e
      return e
    end
    
    return response
  end
  
  
  def makeCallToPackets(params)
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    length = 5
    
    paramsToSend = {:key => key, :length => length, :sort => "desc"}
    
    begin
      response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/packets", :body=> paramsToSend).body
      response = JSON.parse(response)
      settings.log.debug response
      
      total = response["total"]
      unless total.nil?
      
        settings.log.debug "Total number of packets in the gateway: #{total.to_s}"
        
        if total > 5
          
          offset = total - 5
          
          paramsToSend = {:key => key, :length => length, :sort => "desc", :offset => offset}
          response = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/packets", :body=> paramsToSend).body
          response = JSON.parse(response)
          settings.log.debug response
          
        end
      end
      
      response = JSON.pretty_generate(response)
    
    rescue Exception => e
      settings.log.debug e
      return e
    end
    
    return response
  end
  
  
  def constructTopology(params)
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    
    paramsToSend = {:key => key}
    
    zonelist = Array.new
    
    begin
      zones = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/zones", :body=> paramsToSend).body
      nodes = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/nodes", :body=> paramsToSend).body
      
      zones = JSON.parse(zones)
      nodes = JSON.parse(nodes)      
      
      zones["zones"].each do |i|
        zonename = i["zonename"]
        nodelist = Array.new
        
        i["nodes"].each do |j|
          nodename = j
          sensorlist = Array.new
          
          nodes["nodes"].each do |k|
            if nodename == k["name"]
              sensorlist = k["sensors"]
            end
          end
          
          nodelist << {:name=> nodename, :sensorlist=> sensorlist}
        end
        
        zonelist << {:zonename=>zonename, :nodes=>nodelist}
      end
      
      response = zonelist
      
    rescue Exception => e
      settings.log.debug e
      return e
    end
    
    settings.log.debug response.inspect
    return response
  end


  def topologyParser(topology)
      
      settings.log.debug "Number of Zones: #{topology.count.to_s}"
      response = ""           # Will hold our response
      offset = 0              # Offset 
      totalsensorcount = countSensors(topology)    
      settings.log.debug "Total Sensor Count: " + totalsensorcount.to_s
      
      # Canvas height
      defaultheight = 700
      height = 100 + (totalsensorcount * 100)
      if height <= defaultheight
        height = defaultheight 
        settings.log.debug "Height less than defaultheight, setting canvas height to 700"
      end
      settings.log.debug "Canvas height: " + height.to_s
    
      # Set up the Canvas
      response += "var paper = new Raphael(document.getElementById('topology-canvas'), " +
                                      "500, #{height});\n"
                                      
      
    
      # Draw the graph
      topology.each_with_index do |i, index|
        
        # Initial hookup line
        response += "var hookup1 = paper.path('M 50 #{75 + offset} l 50 0');\n"
        
        # Print the Zone name
        response += "var zonetitle = paper.text(50, #{20+ offset}, '#{i[:zonename]}').attr({'font-size':20});"
        
        # Print the sensors
        i[:nodes].each_with_index do |j, jndex|
          
          # Print the node
          response += "var node = paper.path('M 100 #{100 + offset} " +
                              "l 0 -50 l 50 0 l 0 50 l -50 0').attr(" +
                              "{fill: 'red', 'href':'/gateway/data/#{j[:name]}'});\n"
          
          # Print the node name
          response += "var nodetitle = paper.text(125, #{40 + offset}, '#{j[:name]}');"
          
          
          # Print the link to next node
          if i[:nodes].count > 1 
            unless (jndex + 1) == i.count
              response += "var nextnode1 = paper.path('M 75 #{75 + offset} l 0 " +
                          "#{(j[:sensorlist].count * 100) + 75} " +
                          "l 25 0');"
            end
          end
          
          # Print the sensors
          j[:sensorlist].each_with_index do |k, kndex|
            # Sensor 1 in each node is drawn slightly differently
            if kndex == 0 
              response += "var line = paper.path('M 150 #{75 + offset} l 100 0');\n"
              response += "var circle = paper.circle(270, #{ 75 + offset}" +
                          ", 20).attr({fill:'green'});\n"
              
              # Print sensortitle
              response += "var sensor1Title = paper.text(350, #{75 + offset}, '#{k}');"
              
              offset += 75
            else              
            # Sensors beyond first
              response += "var line = paper.path('M 200 #{offset} l 0 75 l 50 0');"
              response += "var circle = paper.circle(270, #{ 75 + offset}, 20).attr({fill:'green'});\n"
              
              # Print sensortitle
              response += "var sensor1Title = paper.text(350, #{75 + offset}, '#{k}');"
              
              offset += 75
            end
            
          end
          offset += 100
        end
      
      end    

    return response
  end
  
  
  def countSensors(topology)
    count = 0
    topology.each do |i|
      unless i[:nodes].nil?
        i[:nodes].each do |j|
          unless j[:sensorlist].nil?
            count += j[:sensorlist].count
          end
        end
      end
    end
    return count
  end

  
  def makeCallToData(params)
    # In here create the highchart js chart and return it for inclusion into the tech-demo site    
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    paramsToSend = {:key => key, :name => params["node"], :node => params["node"]}
    
    begin
      settings.log.debug "Node name: " + params["node"]
      
      nodes = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/nodes", :body=> paramsToSend).body
      
      settings.log.debug nodes
      
      nodes = JSON.parse(nodes)
      
      if nodes["found"] == 0 then settings.log.debug "Zero results found"; end
      
      if nodes["found"] == 1
        packetNo = nodes["nodes"][0]["packets"]
        settings.log.debug "Number of packets available: #{packetNo.to_s}"
        if packetNo > 100
          settings.log.debug "Number of packets exceeds the default limit of 100, requires multiple calls"
        else
          settings.log.debug "Number of packets is within the default limit of 100, requires single call"
        end
        
        times, data = retrievePacketData(paramsToSend, nodes)
      end
    
    rescue Exception => e
      raise e
    end    
    
    return params["node"], times, data
  end



  def retrievePacketData(params, nodes)
    theOffset = (nodes["nodes"][0]["packets"]).to_i - 60
    
    params[:offset] = theOffset
    params[:length] = 60
    packets = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/packets", :body=> params).body
    packets = JSON.parse(packets)
    
    time = ""
    data = ""
    
    packets["packets"].each_with_index do |i, index|
      if index == (packets["packets"].size - 1)
        time += "'" + i["hour"] + ":" + i["minute"] + "'"
      else
        time += "'" + i["hour"] + ":" + i["minute"] + "'," 
      end
    end
    
    nodes["nodes"][0]["sensors"].each_with_index do |i, index|
      theData = Array.new
        
      packets["packets"].each_with_index do |j, jndex|
        theData << j["data"][index]
      end
      
      data += "{name:'#{i}', data:#{theData.to_s}}"
      
      unless index == (nodes["nodes"][0]["sensors"].size - 1) then data += ","; end
    end
    
    return time, data
  end


  def makeCallToZoneStats(params)
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    params[:key] = key
    
    begin
      zones = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/zones", :body=> params).body
      zones = JSON.parse(zones)
      
      settings.log.debug "Number of Zones being managed: #{zones["zones"].size.to_s}"
      
      theZoneData = Array.new
      
      zones["zones"].each do |i|
        settings.log.debug "Zonename: #{i["zonename"]}"
        settings.log.debug "Number of Nodes in this zone: #{i["nodes"].size.to_s}"
      
        theNodeData = Array.new
      
        i["nodes"].each do |j|
          settings.log.debug "Nodename: #{j}"
          response = makeCallToNodes({:name=> j, :nopretty=>true})
          response = JSON.parse(response)
          
          packets = response["nodes"][0]["packets"].to_s
          
          settings.log.debug "Packets associated with this node: #{packets}"
          
          theNodeData << {:name=> j, :packets=> packets}
        end
        
        theZoneData << {:name=> i["zonename"], :nodes=> theNodeData}
      end
      
      
    rescue Exception=> e
      raise e
    end
    return theZoneData
  end
  
  
  def constructPunchcardGraph(params)
    key = "1230aea77d7bd38898fec74a75a87738dea9f657"
    theParams = {:key=>key, :node=>params[:node]}
    
    data = Array.new
    days = Array.new
    
    today = DateTime.now
    year = today.year
    month = today.month
    
    theStart = "%02d" % (today.day.to_i - 6)
    theEnd = "%02d" % (today.day.to_i)
    theDate = today.year.to_s() + "-" + "%02d" % today.month.to_s() + "-"
    settings.log.debug "From #{theStart} to #{theEnd}"
    
    (theStart..theEnd).each do |i|
      days << DateTime.new(year, month, i.to_i).strftime('%a')
      (0..23).each do |j|
        theParams[:hour] = "%02d" % j
        theParams[:date] = theDate + i.to_s
        
        #settings.log.debug theParams.inspect
        
        nodes = Typhoeus::Request.get("http://#{settings.ardtweenouri}:#{settings.ardtweenoport}/api/v1/packets", :body=> theParams).body
        nodes = JSON.parse(nodes)
        
        #settings.log.debug nodes["found"]
        data << nodes["found"].to_i
      end  
    end
    
    settings.log.debug days.inspect
    
    return data, days.reverse
  end



# End of ArdtweenoDemo Class
end
