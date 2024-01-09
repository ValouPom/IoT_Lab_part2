/*  
 *  ------ LoRaWAN Code Example -------- 
 *  
 *  Explanation: This example shows how to configure the module and
 *  send frames to a LoRaWAN gateway with ACK after join a network
 *  using OTAA
 *  
 *  Copyright (C) 2017 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see .  
 *  
 *  Version:           3.1
 *  Design:            David Gascon 
 *  Implementation:    Luis Miguel Marti
 */

//Include Libraries
#include <WaspSensorAgr_v30.h> 
#include <WaspLoRaWAN.h>
#include <WaspFrame.h>

//Variable to store the value of sensor
float temp,humd,pres;
float tempPT1000;
float watermark1;
pt1000Class pt1000Sensor;

// socket to use
//////////////////////////////////////////////
uint8_t socket = SOCKET0;
watermarkClass wmSensor1(SOCKET_1);
//////////////////////////////////////////////

// Device parameters for Back-End registration
////////////////////////////////////////////////////////////
char DEVICE_EUI[]  = "70B3D57ED0063B39";
char APP_EUI[] = "0102030405067788";
char APP_KEY[] = "31D84892407C62AE2B4A479D52772588";
////////////////////////////////////////////////////////////

// Define port to use in Back-End: from 1 to 223
uint8_t PORT = 3;

// variable
uint8_t error;

// define the Waspmote ID 
char moteID[] = "lullaby";


void setup() 
{
  USB.ON();
  USB.println(F("Start program\n"));
  USB.println(F("Start LoRa module\n"));


  USB.println(F("------------------------------------"));
  USB.println(F("Module configuration"));
  USB.println(F("------------------------------------\n"));


  //////////////////////////////////////////////
  // 0. Turn on the sensor board
  //////////////////////////////////////////////
  Agriculture.ON(); 


  //////////////////////////////////////////////
  // 1. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 2. Set Device EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Device EUI set OK"));     
  }
  else 
  {
    USB.print(F("2. Device EUI set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 3. Set Application EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("3. Application EUI set OK"));     
  }
  else 
  {
    USB.print(F("3. Application EUI set error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 4. Set Application Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Application Key set OK"));     
  }
  else 
  {
    USB.print(F("4. Application Key set error = ")); 
    USB.println(error, DEC);
  }

  /////////////////////////////////////////////////
  // 5. Join OTAA to negotiate keys with the server
  /////////////////////////////////////////////////
  
  error = LoRaWAN.joinOTAA();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("5. Join network OK"));         
  }
  else 
  {
    USB.print(F("5. Join network error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 6. Save configuration
  //////////////////////////////////////////////

  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("6. Save configuration OK"));     
  }
  else 
  {
    USB.print(F("6. Save configuration error = ")); 
    USB.println(error, DEC);
  }

  //////////////////////////////////////////////
  // 7. Switch off
  //////////////////////////////////////////////

  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("7. Switch OFF OK"));     
  }
  else 
  {
    USB.print(F("7. Switch OFF error = ")); 
    USB.println(error, DEC);
  }

  
  USB.println(F("\n---------------------------------------------------------------"));
  USB.println(F("Module configured"));
  USB.println(F("After joining through OTAA, the module and the network exchanged "));
  USB.println(F("the Network Session Key and the Application Session Key which "));
  USB.println(F("are needed to perform communications. After that, 'ABP mode' is used"));
  USB.println(F("to join the network and send messages after powering on the module"));
  USB.println(F("---------------------------------------------------------------\n"));
  USB.println();  
  
  frame.setID(moteID);

}



void loop() 
{

  //////////////////////////////////////////////
  // 0. Get sensor value
  //////////////////////////////////////////////
  watermark1 = (int32_t)(wmSensor1.readWatermark());  
  temp = (int32_t)(Agriculture.getTemperature());
  humd  = (int32_t)(Agriculture.getHumidity());
  pres = (int32_t)(Agriculture.getPressure());  
  tempPT1000 = (int32_t)(pt1000Sensor.readPT1000());


  //////////////////////////////////////////////
  // 1. Creating a new frame
  //////////////////////////////////////////////
  USB.println(F("Creating an ASCII frame"));

  // Create new frame (ASCII)
  frame.createFrame(BINARY); 

  // set frame fields (Temperature, humidity, pression, moisture)
  frame.addSensor(SENSOR_AGR_TC, temp);
  frame.addSensor(SENSOR_AGR_HUM, humd);
  frame.addSensor(SENSOR_AGR_PRES, pres);
  frame.addSensor(SENSOR_AGR_SOIL1,watermark1);
  frame.addSensor(SENSOR_AGR_SOILTC,tempPT1000);

  // Prints frame
  frame.showFrame();
  
  //////////////////////////////////////////////
  // 2. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 3. Join network
  //////////////////////////////////////////////

  error = LoRaWAN.joinABP();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("2. Join network OK")); 

    //////////////////////////////////////////////
    // 4. Send confirmed packet 
    //////////////////////////////////////////////

    error = LoRaWAN.sendUnconfirmed( PORT, frame.buffer, frame.length);

    // Error messages:
    /*
     * '6' : Module hasn't joined a network
     * '5' : Sending error
     * '4' : Error with data length    
     * '2' : Module didn't response
     * '1' : Module communication error   
     */
    // Check status
    if( error == 0 ) 
    {
      USB.println(F("3. Send confirmed packet OK"));     
      if (LoRaWAN._dataReceived == true)
      { 
        USB.print(F("   There's data on port number "));
        USB.print(LoRaWAN._port,DEC);
        USB.print(F(".\r\n   Data: "));
        USB.println(LoRaWAN._data);
      }
    }
    else 
    {
      USB.print(F("3. Send confirmed packet error = ")); 
      USB.println(error, DEC);
    }    
  }
  else 
  {
    USB.print(F("2. Join network error = ")); 
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 5. Switch off
  //////////////////////////////////////////////

  error = LoRaWAN.OFF(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("4. Switch OFF OK"));     
  }
  else 
  {
    USB.print(F("4. Switch OFF error = ")); 
    USB.println(error, DEC);
  }


  USB.println();
  delay(30000);



}
