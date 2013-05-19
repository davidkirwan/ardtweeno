####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno Node Firmware
#
# @date         06-04-2013
####################################################################################################

int pin = 2;
int sensorValue = 0;
int led = 13;

String str;
double val;
char tmp[10];

// Ardtweeno Configuration
// Ardtweeno Node Authentication Key
String key = "f937c37e949d9efa20d2958af309235c73ec039a";
// Node0 - 500d81aafe637717a52f8650e54206e64da33d27
// Node1 - f937c37e949d9efa20d2958af309235c73ec039a

void setup() 
{ 
  Serial.begin(9600);
  pinMode(pin, INPUT_PULLUP);
  pinMode(led, OUTPUT);
  delay(2000);
  str = "";
  val = 0.0;
} 


void loop() 
{
  sensorValue = digitalRead(pin);
  Serial.println(sensorValue);
  
  if(sensorValue == 0)
  {
    delay(250);
    sensorValue = digitalRead(pin);
    if(sensorValue == 0)
    {
      digitalWrite(led, HIGH);
      str = "{\"data\":[";  
      dtostrf(val, 2, 2, tmp);  
      str = str + tmp;
      str = str + "],\"key\":\"";
      str = str + key;
      str = str + "\"}";
  
      Serial.println(str);
      delay(10000);
      digitalWrite(led, LOW);
    }
  }
  delay(1000);
}