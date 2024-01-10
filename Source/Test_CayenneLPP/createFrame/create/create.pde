/*
  Valerie Pompili
  Abdi Vural

  application Smart Agriculture 
*/

// Put your libraries here (#include ...)

#define LPP_TEMPERATURE           103 //2 bytes, 0.1°C signed
#define LPP_RELATIVE_HUMIDITY     104 //1 byte, 0.5% unsigned
#define LPP_BAROMETRIC_PRESSURE   115 //2 bytes 0.1 hPA Unsigned 
#define LPP_LUMINOSITY            101 // 2 bytes, here to stock moisture (KHz)

#define LPP_TEMPERATURE_SIZE           4 //2 bytes, 0.1°C signed
#define LPP_LUMINOSITY_SIZE            4 // Use here to stock moisture 
#define LPP_RELATIVE_HUMIDITY_SIZE     3 //1 byte, 0.5% unsigned
#define LPP_BAROMETRIC_PRESSURE_SIZE   4 //2 bytes 0.1 hPA Unsigned
#define FRAME_SIZE                     27

uint8_t bufferFrame[FRAME_SIZE];
uint8_t cursor; 

#include <WaspSensorAgr_v30.h>
#include <WaspLoRaWAN.h>
//Variable to store the value of sensor
float temp,humd,pres;
float tempPT1000;
float watermark1;
pt1000Class pt1000Sensor;
watermarkClass wmSensor1(SOCKET_1);
int16_t temp1,temp2;
uint16_t pressure,moisture;



// Device parameters for Back-End registration
////////////////////////////////////////////////////////////
char DEVICE_EUI[]  = "70B3D57ED00640B1";
char APP_EUI[] = "0102030405067788";
char APP_KEY[] = "302407F23A3722E99247EA1A3A1450E6";

uint8_t socket = SOCKET0;
////////////////////////////////////////////////////////////
// Define port to use in Back-End: from 1 to 223
uint8_t PORT = 3;

// variable
uint8_t error;


//------------------------------------------Start Constructor Frame-------------------------------------------------

uint8_t addTemperature(uint8_t channel, int16_t val) {
    if ((cursor + LPP_TEMPERATURE_SIZE) > FRAME_SIZE) {
        return 0;
    }
    bufferFrame[cursor++] = channel; 
    bufferFrame[cursor++] = LPP_TEMPERATURE; 
    bufferFrame[cursor++] = val >> 8; 
    bufferFrame[cursor++] = val; 

    return cursor;
}

uint8_t addRelativeHumidity(uint8_t channel, uint16_t rh) {
    if ((cursor + LPP_RELATIVE_HUMIDITY_SIZE) > FRAME_SIZE) {
        return 0;
    }
    bufferFrame[cursor++] = channel; 
    bufferFrame[cursor++] = LPP_RELATIVE_HUMIDITY; 
    bufferFrame[cursor++] = rh; 

    return cursor;
}

uint8_t addBarometricPressure(uint8_t channel, int16_t val) {
    if ((cursor + LPP_BAROMETRIC_PRESSURE_SIZE) > FRAME_SIZE) {
        return 0;
    }
    
    bufferFrame[cursor++] = channel; 
    bufferFrame[cursor++] = LPP_BAROMETRIC_PRESSURE; 
    bufferFrame[cursor++] = val >> 8; 
    bufferFrame[cursor++] = val; 

    return cursor;
}

uint8_t addBarometricPressure(uint8_t channel, uint16_t val) {
    if ((cursor + LPP_BAROMETRIC_PRESSURE_SIZE) > FRAME_SIZE) {
        return 0;
    }
    
    bufferFrame[cursor++] = channel; 
    bufferFrame[cursor++] = LPP_BAROMETRIC_PRESSURE; 
    bufferFrame[cursor++] = val >> 8; 
    bufferFrame[cursor++] = val; 

    return cursor;
}

uint8_t addLuminosity(uint8_t channel, uint16_t lux) {
    if ((cursor + LPP_LUMINOSITY_SIZE) > FRAME_SIZE) {
        return 0;
    }
    bufferFrame[cursor++] = channel; 
    bufferFrame[cursor++] = LPP_LUMINOSITY; 
    bufferFrame[cursor++] = lux >> 8; 
    bufferFrame[cursor++] = lux; 

    return cursor;
}

//------------------------------------------END Constructor Frame-------------------------------------------------

void getValue()
{
  watermark1 = wmSensor1.readWatermark();  
  temp = Agriculture.getTemperature();
  humd  = Agriculture.getHumidity();
  pres = Agriculture.getPressure();  
  tempPT1000 = pt1000Sensor.readPT1000();

 temp1=temp*10;
 temp2=tempPT1000*10;
 pressure=pres/10;
 moisture=watermark1/100;
}

void printValue()
{
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

}



void setup()
{
  
  USB.ON();
  USB.println(F("Start program\n"));
  Agriculture.ON();


  //----------------LoRa Transmission----------------------
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
  USB.println(F("Module configured - join OTAA"));

  USB.println(F("---------------------------------------------------------------\n"));
  USB.println(); 
}


void loop()
{
  


  //////////////////////////////////////////////
  // 1. Creating a new frame
  //////////////////////////////////////////////
  // RESET Value

  cursor = 0;

  //GET Value 
  getValue();
  printValue();
  
  addTemperature(1,temp1);
  addTemperature(2,temp2);
  addRelativeHumidity(3,humd*2);
  addBarometricPressure(4,pressure);
  addLuminosity(5,moisture);

  for(int i = 0;i<cursor;i++)
  {
    USB.printf("int: %d\n", bufferFrame[i]);
  }
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

    error = LoRaWAN.sendUnconfirmed( PORT, bufferFrame, cursor);

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
