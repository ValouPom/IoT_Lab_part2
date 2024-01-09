/*
    ------ LoRaWAN Code Example --------

    Explanation: This example shows how to configure the module and
    send tiny frames to a LoRaWAN gateway with ACK after join a network
    using OTAA.

    This type of frame has been designed to create short frames with data.

    Copyright (C) 2019 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see .

    Version:           3.0
    Design:            David Gascon
    Implementation:    Isabel Burillo
*/

#include <WaspLoRaWAN.h>
#include <WaspSensorAgr_v30.h> 
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
uint8_t error_config = 0;

// define the Waspmote ID
char moteID[] = "node_01";


void setup()
{
  USB.ON();
  
  USB.println(F("LoRaWAN example - Send Confirmed packets (ACK)\n"));
  Agriculture.ON(); 

  USB.println(F("------------------------------------"));
  USB.println(F("Module configuration"));
  USB.println(F("------------------------------------\n"));


  //////////////////////////////////////////////
  // 1. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("1. Switch ON OK"));
  }
  else
  {
    USB.print(F("1. Switch ON error = "));
    USB.println(error, DEC);
    error_config = 1;
  }


  //////////////////////////////////////////////
  // 2. Change data rate
  //////////////////////////////////////////////

  error = LoRaWAN.setDataRate(3);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("2. Data rate set OK"));
  }
  else
  {
    USB.print(F("2. Data rate set error= "));
    USB.println(error, DEC);
    error_config = 2;
  }


  //////////////////////////////////////////////
  // 3. Set Device EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("3. Device EUI set OK"));
  }
  else
  {
    USB.print(F("3. Device EUI set error = "));
    USB.println(error, DEC);
    error_config = 3;
  }

  //////////////////////////////////////////////
  // 4. Set Application EUI
  //////////////////////////////////////////////

  error = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("4. Application EUI set OK"));
  }
  else
  {
    USB.print(F("4. Application EUI set error = "));
    USB.println(error, DEC);
    error_config = 4;
  }

  //////////////////////////////////////////////
  // 5. Set Application Session Key
  //////////////////////////////////////////////

  error = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("5. Application Key set OK"));
  }
  else
  {
    USB.print(F("5. Application Key set error = "));
    USB.println(error, DEC);
    error_config = 5;
  }

  /////////////////////////////////////////////////
  // 6. Join OTAA to negotiate keys with the server
  /////////////////////////////////////////////////

  error = LoRaWAN.joinOTAA();

  // Check status
  if ( error == 0 )
  {
    USB.println(F("6. Join network OK"));
  }
  else
  {
    USB.print(F("6. Join network error = "));
    USB.println(error, DEC);
    error_config = 6;
  }


  //////////////////////////////////////////////
  // 7. Save configuration
  //////////////////////////////////////////////

  error = LoRaWAN.saveConfig();

  // Check status
  if ( error == 0 )
  {
    USB.println(F("7. Save configuration OK"));
  }
  else
  {
    USB.print(F("7. Save configuration error = "));
    USB.println(error, DEC);
    error_config = 7;
  }

  //////////////////////////////////////////////
  // 8. Switch off
  //////////////////////////////////////////////

  error = LoRaWAN.OFF(socket);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("8. Switch OFF OK"));
  }
  else
  {
    USB.print(F("8. Switch OFF error = "));
    USB.println(error, DEC);
    error_config = 8;
  }

  if (error_config == 0) {
    USB.println(F("\n---------------------------------------------------------------"));
    USB.println(F("Module configured"));
    USB.println(F("After joining through OTAA, the module and the network exchanged "));
    USB.println(F("the Network Session Key and the Application Session Key which "));
    USB.println(F("are needed to perform communications. After that, 'ABP mode' is used"));
    USB.println(F("to join the network and send messages after powering on the module"));
    USB.println(F("---------------------------------------------------------------\n"));
    USB.println();
  }
  else {
    USB.println(F("\n---------------------------------------------------------------"));
    USB.println(F("Module not configured"));
    USB.println(F("Check OTTA parameters and reestart the code."));
    USB.println(F("If you continue executing the code, frames will not be sent."));
    USB.println(F("\n---------------------------------------------------------------"));
  }

  frame.setID(moteID);

}



void loop()
{

//////////////////////////////////////////////
  // 0. Get sensor value
  //////////////////////////////////////////////
  watermark1 = (int16_t)wmSensor1.readWatermark();  
  temp = (int16_t) Agriculture.getTemperature();
  humd  = (int16_t)Agriculture.getHumidity();
  pres = (int16_t)Agriculture.getPressure();  
  tempPT1000 = (int16_t)pt1000Sensor.readPT1000();

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

  //////////////////////////////////////////////
  // 1. Creating a new frame
  //////////////////////////////////////////////

 

  USB.println(F("1. Creating an BINARY frame"));

  // Create new frame
  frame.createFrame(BINARY);

  // set frame fields (Battery sensor - uint8_t)
// set frame fields (Temperature, humidity, pression, moisture)
  frame.addSensor(SENSOR_AGR_TC, temp);
  frame.addSensor(SENSOR_AGR_HUM,  humd);
  frame.addSensor(SENSOR_AGR_PRES,  pres);
  frame.addSensor(SENSOR_AGR_SOIL1, watermark1);
  frame.addSensor(SENSOR_AGR_SOILTC, tempPT1000);

  // Prints frame
  frame.showFrame();

 


  //////////////////////////////////////////////
  // 2. Switch on
  //////////////////////////////////////////////

  error = LoRaWAN.ON(socket);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("2. Switch ON OK"));
  }
  else
  {
    USB.print(F("2. Switch ON error = "));
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 3. Join network
  //////////////////////////////////////////////

  error = LoRaWAN.joinABP();

  // Check status
  if ( error == 0 )
  {
    USB.println(F("3. Join network OK"));

    error = LoRaWAN.getMaxPayload();

    if (error == 0)
    {
      //////////////////////////////////////////////
      // 4. Generate tiny frame
      //////////////////////////////////////////////

      USB.print(F("4.1. LoRaWAN maximum payload: "));
      USB.println(LoRaWAN._maxPayload, DEC);

      // set maximum payload
      frame.setTinyLength(LoRaWAN._maxPayload);

      boolean end = false;
      uint8_t pending_fields = 0;

      while (end == false)
      {
        pending_fields = frame.generateTinyFrame();

        USB.print(F("4.2. Tiny frame generated:"));
        USB.printHexln(frame.bufferTiny, frame.lengthTiny);


        //////////////////////////////////////////////
        // 5. Send confirmed packet
        //////////////////////////////////////////////

        USB.println(F("5. LoRaWAN confirmed sending..."));
        error = LoRaWAN.sendUnconfirmed( PORT, frame.bufferTiny, frame.lengthTiny);

        // Error messages:
        /*
          '6' : Module hasn't joined a network
          '5' : Sending error
          '4' : Error with data length
          '2' : Module didn't response
          '1' : Module communication error
        */
        // Check status
        if (error == 0)
        {
          USB.println(F("5.1. LoRaWAN send packet OK"));
          if (LoRaWAN._dataReceived == true)
          {
            USB.print(F("  There's data on port number: "));
            USB.print(LoRaWAN._port, DEC);
            USB.print(F("\r\n  Data: "));
            USB.println(LoRaWAN._data);
          }
        }
        else
        {
          USB.print(F("5.1. LoRaWAN send packet error = "));
          USB.println(error, DEC);
        }

        if (pending_fields > 0)
        {
          end = false;
          delay(10000);
        }
        else
        {
          end = true;
        }
      }
    }
    else
    {
      USB.println(F("4. LoRaWAN error getting the maximum payload"));
    }
  }
  else
  {
    USB.print(F("2. Join network error = "));
    USB.println(error, DEC);
  }


  //////////////////////////////////////////////
  // 6. Switch off
  //////////////////////////////////////////////

  error = LoRaWAN.OFF(socket);

  // Check status
  if ( error == 0 )
  {
    USB.println(F("6. Switch OFF OK"));
  }
  else
  {
    USB.print(F("6. Switch OFF error = "));
    USB.println(error, DEC);
  }


  USB.println();
  delay(30000);



}
