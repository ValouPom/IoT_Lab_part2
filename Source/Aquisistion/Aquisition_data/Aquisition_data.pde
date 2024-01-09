#include <WaspFrame.h>
#include <WaspSensorAgr_v30.h>

// Variable to store the read value
float temp,humd,pres;
float tempPT1000;
float watermark1;
//Instance object
pt1000Class pt1000Sensor;
watermarkClass wmSensor1(SOCKET_1);
void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("Start program"));
 
  // Turn on the sensor board
  Agriculture.ON(); 
}
 
void loop()
{
  ///////////////////////////////////////
  // 1. Read BME280: temp, hum, pressure
  /////////////////////////////////////// 
  watermark1 = wmSensor1.readWatermark();  
  temp = Agriculture.getTemperature();
  humd  = Agriculture.getHumidity();
  pres = Agriculture.getPressure();  
  tempPT1000 = pt1000Sensor.readPT1000(); 


  USB.println(F("Creating an ASCII frame"));
  frame.createFrame(ASCII);
  frame.addSensor(SENSOR_AGR_TC, temp);
  frame.addSensor(SENSOR_AGR_HUM, humd);
  frame.addSensor(SENSOR_AGR_PRES, pres);
  frame.addSensor(SENSOR_AGR_SOIL1,watermark1);
  frame.addSensor(SENSOR_AGR_SOILTC,tempPT1000);
  frame.showFrame();

  
  
  
  ///////////////////////////////////////
  // 2. Print BME280 Values
  ///////////////////////////////////////
  USB.print(F("Temperature: "));
  USB.print(temp);
  USB.println(F(" Celsius"));
  USB.print(F("Humidity: "));
  USB.print(humd);
  USB.println(F(" %"));  
  USB.print(F("Pressure: "));
  USB.print(pres);
  USB.println(F(" Pa"));  
  USB.println(); 
  USB.print(F("PT1000: "));
  USB.printFloat(tempPT1000,3);
  USB.println(F(" ºC"));
  USB.print(F("Watermark 1 - Frequency: "));
  USB.print(watermark1);
  USB.println(F(" Hz"));




  
  delay(10000);
  
}


