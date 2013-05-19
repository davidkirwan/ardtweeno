####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno Node Firmware
#
# @date         26-03-2013
####################################################################################################

#include <OneWire.h>
#include <DallasTemperature.h>

// Library Configuration
// Data wire is plugged into port 2 on the Arduino
#define ONE_WIRE_BUS 2
// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
// Pass our oneWire reference to Dallas Temperature. 
DallasTemperature sensors(&oneWire);

// System Variables
String str;
double val;
char tmp[10];

/*
Ardtweeno Node Authentication Key
*/
String key = "500d81aafe637717a52f8650e54206e64da33d27";
// Node0 - 500d81aafe637717a52f8650e54206e64da33d27
// Node1 - f937c37e949d9efa20d2958af309235c73ec039a

void setup() 
{ 
  Serial.begin(9600);
  delay(2000);
  sensors.begin();
  str = "";
  val = 0.0;
} 


void loop() 
{
  sensors.requestTemperatures(); // Send the command to get temperatures
  str = "{\"data\":[";
  val = sensors.getTempCByIndex(0);
  
  dtostrf(val, 2, 2, tmp);
  
  str = str + tmp;
  str = str + "],\"key\":\"";
  str = str + key;
  str = str + "\"}";
  
  Serial.println(str);
  
  delay(60000);
}