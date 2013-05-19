var serialport = require("serialport");
var SerialPort = serialport.SerialPort;
var needle = require('needle');

// Read in the ARGV object parameters and remove the first two which hold the node variable
// and the name of the script file.
var myArgs = process.argv.slice(2);

// Check to ensure the remaining parameters size is 2
if(!(myArgs.length == 3)){
  console.log("Usage: node serialparser.js /dev/ttyUSB0 9600 adminkey");
  process.exit();
}

var dev = myArgs[0];
var options = {
  parser: serialport.parsers.raw,
  baudrate: parseInt(myArgs[1])
};

var sp = new SerialPort(dev, options);
var tempData = "";
var attempts = 0;

sp.on("data", function (data) {
  data = data.toString().trim();

  console.log("Data received: " + data);

  try {
    if(attempts > 0){
      throw new Error('Preventing loss of data in buffer');
    }
    JSON.parse(data);
    tempData = "";
    attempts = 0;
    console.log("Data for transmit: " + data);
    var theData = 'key=' + myArgs[2] + '&payload=' + data

    needle.post('http://localhost:4567/api/v1/packets', theData, function(err, resp, body){
      try {
        console.log("Got status code: " + resp.statusCode);
        // you can pass params as a string or as an object
      } catch (e){
        console.log(e.message)
      }
    });

  } catch (e) {
    tempData += data;
    tempData = tempData.trim();

    if(attempts < 15){
      try {
        JSON.parse(tempData);
        data = tempData;
        tempData = "";
        attempts = 0;
        console.log("Data for transmit: " + data);
        var theData = 'key=' + myArgs[2] + '&payload=' + data

        needle.post('http://localhost:4567/api/v1/packets', theData, function(err, resp, body){
        try {
          console.log("Got status code: " + resp.statusCode);
          // you can pass params as a string or as an object
        } catch (e){
            console.log(e.message)
          }
        });

      } catch(e){
        console.log("buffer contains: " + tempData);
        console.log("Nope still not a valid JSON string, buffering...");
      }
      
    }
    else
    {
      tempData = "";
      attempts = 0;
    }
    attempts += 1;
  }
});
