#include <Servo.h>
#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include "Boards.h"

//-----------------------CUSTOM-----------------------
//Pins
#define LED_PIN 2
#define SERVO_PIN 4
#define BUTTON_PIN 6
#define POT_PIN A0

//Servo
Servo my_servo;

//Button
int buttonState = 0;         
int lastButtonState = 0;  

//Potentiometer
int potState = 0;         
int lastPotState = 0;  
int potSensorValue = 0;         // the sensor value
int potSensorMin = 1023;        // minimum sensor value
int potSensorMax = 0;          

void setup()
{
  Serial.begin(57600);
  Serial.println("BLE LTI Team");

  //LED
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, HIGH);

  //Button
  pinMode(BUTTON_PIN, INPUT);

  //Pot - calibrate
  while (millis() < 5000) {
    potSensorValue = analogRead(POT_PIN);

    // record the maximum sensor value
    if (potSensorValue > potSensorMax) {
      potSensorMax = potSensorValue;
    }

    // record the minimum sensor value
    if (potSensorValue < potSensorMin) {
      potSensorMin = potSensorValue;
    }
  }
  // signal the end of the calibration period
  digitalWrite(LED_PIN, LOW);
  
  // Init. and start BLE library.
  ble_begin();
}

void loop()
{
  while(ble_available())
  {
    byte cmd;
    cmd = ble_read();
    Serial.print("Command: ");
    Serial.write(cmd);
    Serial.println();
    
    // Parse data here
    switch (cmd)
    {          
      case 'B': //iOS switch -> LED on and off
        {
          byte on = ble_read();

          digitalWrite(LED_PIN, on);
          if(on){
            Serial.println("  Value: ON");
          }else{
            Serial.println("  Value: OFF");
          }
          
        }
        break;
      case 'D': //iOS slider -> PWM move servo
        {
          byte value = ble_read();
          Serial.print("  Value: ");
          Serial.print(value);
          Serial.println();
          my_servo.attach(SERVO_PIN);
          my_servo.write(value);
          delay(2000);
          my_servo.detach();
        }
        break;
    }

    // send out any outstanding data
    ble_do_events();
    
    return; // only do this task in this loop
  }

  //Board button -> iOS
  buttonState = digitalRead(BUTTON_PIN);
  if (buttonState != lastButtonState) {
    if (buttonState == HIGH) {
      ble_write('F');
      ble_write('1');
      Serial.println("Button: ON");
    } else {
      ble_write('F');
      ble_write('0');
      Serial.println("Button: OFF");
    }
    delay(50);
  }
  lastButtonState = buttonState;

  //Potentiometer -> iOS
  potState = analogRead(POT_PIN);
  potState = map(potState, potSensorMin, potSensorMax, 0, 255);
  potState = analogRead(POT_PIN);

  if (abs(lastPotState - potState) > 10) {
    lastPotState = potState;
    ble_write('E');

    char str[10];
    itoa(potState, str, 10);
    int i = 0;
    while(str[i] != '\0') {
        ble_write(str[i++]);
    }
    Serial.print("Pot state: ");
    Serial.println(potState);
    delay(500);
  }
  
    
  ble_do_events();
}

