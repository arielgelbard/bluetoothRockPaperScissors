//Rock, Paper, Scissors Glove
//By: Tristan Darwent & Ariel Gelbard
//Date: April 2, 2015

//Include Software Serial Library
#include <SoftwareSerial.h>

#include <Adafruit_NeoPixel.h>
#include <avr/power.h>

// Which pin on the Arduino is connected to the NeoPixels?
// On a Trinket or Gemma we suggest changing this to 1
#define PIN            3

// How many NeoPixels are attached to the Arduino?
#define NUMPIXELS      1

// When we setup the NeoPixel library, we tell it how many pixels, and which pin to use to send signals.
// Note that for older NeoPixel strips you might need to change the third parameter--see the strandtest
// example for more information on possible values.
Adafruit_NeoPixel pixel = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

//Create SoftwareSerial Object called BT
SoftwareSerial BT(10, 9); //TX, RX

//stores commands that were recieved from the bluetooth module
String command;

String choice;

const int flex1pin = 11;
const int flex2pin = 7;

const int threshhold = 500;


//====================
//Setup Interface
void setup() {

//assign BT Object to be on serial communication 9600
BT.begin(9600);

// Open serial communications
Serial.begin(9600);

pixel.begin();
pixel.show();
//  startGame();
}

String choice2;
//====================
//loop checks to see if there was any input from the HC-05 module
void loop() {
if(choice==choice2){
}
else{
BT.println(choice);
choice2=choice;
delay(200);
}
getChoice();


//while module is still available
while ( BT.available() ) {
//Delay added to make thing stable
delay(10);
//read byte from module
char c = BT.read();
//    BT.println(choice);
Serial.println(c);
//if there are no more bytes left to transfer
if (c == '#') {
break; //Exit the loop
}

//append byte value to string that stores a users command
command += c;
Serial.println(c);

}

//if the command holds a value
if (command.length() > 0) {

//print the output of the command to the serial monitor
Serial.println(command);

//if command was 'go'
if (command == "start") {
startGame();
} else if (command == "win") {
checkResults("win");
} else if (command == "lose") {
checkResults("lose");
} else if (command == "draw") {
checkResults("draw");
} else if (command == "1") {
turnBlue();
} else if (command == "0") {
turnOff();
} else if (command == "check") {
//     BT.println(choice);
turnBlue();
BT.println("change");
delay(200);
}

//clear command variable
command="";

}
}

void startGame() {
countdown();
delay(700);
getChoice();
BT.println("change");
delay(10);

// BT.println(choice);
}

void countdown() {
turnBlue();
delay(600);
turnOff();
// delay(400);
// turnBlue();
// delay(300);
// turnOff();
// delay(400);
// turnBlue();
}



void getChoice() {
int flex1position;
int flex2position;
flex1position = analogRead(flex1pin);
flex2position = analogRead(flex2pin);
if (flex1position < threshhold && flex2position > threshhold){
choice = "scissors";
} else if (flex1position < threshhold && flex2position < threshhold){
choice = "rock";
} else {
choice = "paper";
}
Serial.println(flex1position);
Serial.println(flex2position);
}

void checkResults(String result) {
//  delay(1000);
if (result == "win") {
turnGreen();
} else if (result == "lose") {
turnRed();
} else if (result == "draw") {
turnYellow();
}
}

void turnRed() {
pixel.setPixelColor(0, 255, 0, 0);
pixel.show();
}

void turnGreen() {
pixel.setPixelColor(0, 0, 255, 0);
pixel.show();
}

void turnYellow() {
pixel.setPixelColor(0, 255, 255, 0);
pixel.show();
}

void turnBlue() {
pixel.setPixelColor(0, 0, 0, 255);
pixel.show();
}

void turnOff() {
pixel.setPixelColor(0, 0);
pixel.show();
}