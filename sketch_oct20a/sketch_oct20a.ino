#include <SPI.h> 
#include <RFID.h>
#include <Servo.h> 
/*
1-comunicacion entre arduino y pc (hecho)
2-interfaz grafica en processing(hecho)
3-lecturas de sensores o actuadores (hecho)
4-indicar estado mediante leds (hecho)
5-maquina de estados en arduino y processing (hecho)
6-crear una clase (hecho)
7-archivos modo append (hecho)
8-manejo en memoria de datos (hecho)
*/
RFID rfid(10, 9);       //D10:SDA D9:RST 
unsigned char status; 
unsigned char str[MAX_LEN];
char opcion;
String tarjetasAutorizadas [2] = {"0", "19612012715"};  //codigos de las tarjetas autorizadas
int tarjetasAutorizadasSize = 2;
String tarjetaTemporal;                               //Se almacena el codigo de la tarjeta escaneada
Servo Servo1;              
int cerrado = 20;               //posicion inicial del servo
int abierto = 88;             //posicion de apertura
boolean locked = true;
int ledRojo = 5;
int ledVerde = 6;
const int boton1 = 2; // Pin del primer botón
const int boton2 = 7; // Pin del segundo botón
const int boton3 = 4; // Pin del tercer botón
const int boton4 = 8; // Pin del cuarto botón
const int pinBuzzer = A0;

//declaracion de la clase que contiene las funciones relacionadas con las tarjetas
class Funciones
{
  public:
  void abrir(char estado)
  {
     if(estado=='1')
      {
      if (locked == true)        
        {
        Servo1.write(abierto);
        locked = false;
        }
      else if (locked == false) 
        {
        Servo1.write(cerrado);
        locked = true;
        }
      digitalWrite (pinBuzzer, HIGH); 
      delay (200); 
      digitalWrite (pinBuzzer, LOW);
      delay(200);
      digitalWrite (pinBuzzer, HIGH);
      delay(200);
      digitalWrite (pinBuzzer, LOW);
      delay(200);
      digitalWrite(ledVerde, HIGH);    
      delay(200);
      digitalWrite(ledVerde, LOW);
      delay(200);
      digitalWrite(ledVerde, HIGH);
      delay(200);
      digitalWrite(ledVerde, LOW);
      delay(200);
  }
  if (estado== '2')
  {
    digitalWrite(ledRojo, HIGH);      
    delay(200);
    digitalWrite(ledRojo, LOW);
    delay(200);
    digitalWrite(ledRojo, HIGH);
    delay(200);
    digitalWrite(ledRojo, LOW);
    delay(200);
  }
  }
};
Funciones FuncionesTarjetas;
void setup() 
{ 
  Serial.begin(9600);    
  SPI.begin();           
  rfid.init();
  pinMode (pinBuzzer, OUTPUT);
  pinMode(boton1, INPUT);
  pinMode(boton2, INPUT);
  pinMode(boton3, INPUT);
  pinMode(boton4, INPUT);          
  pinMode(ledRojo, OUTPUT);   
  pinMode(ledVerde, OUTPUT);
  digitalWrite(ledRojo, HIGH);
  delay(200);
  digitalWrite(ledVerde, HIGH);
  delay(200);
  digitalWrite(ledRojo, LOW);
  delay(200);
  digitalWrite(ledVerde, LOW);
  Servo1.attach(3);             //Se conecta el servo al pin 3
  Servo1.write(cerrado);         //Mover el servo a la posicion de cierre
} 
void loop() 
{ 
  int estadoBoton1 = digitalRead(boton1);
  int estadoBoton2 = digitalRead(boton2);
  int estadoBoton3 = digitalRead(boton3);
  int estadoBoton4 = digitalRead(boton4);
  Serial.print(estadoBoton1);
  Serial.print(estadoBoton2);
  Serial.print(estadoBoton3);
  Serial.println(estadoBoton4);
  delay(100);
  if (rfid.findCard(PICC_REQIDL, str) == MI_OK)   //se espera a que se acerque una tarjeta
  { 
    String temp = "";                             //Se almacena el codigo de la tarjeta temporalmente
    if (rfid.anticoll(str) == MI_OK)              //Deteccion anti colisiones
    { 
      for (int i = 0; i <= 4; i++)               
      { 
        temp = temp + (0x0F & (str[i] >> 4)); 
        temp = temp + (0x0F & str[i]); 
      } 
      tarjetaTemporal=temp;
    }
    rfid.selectTag(str);
    Serial.println(tarjetaTemporal);
  }
  if (Serial.available() > 0)
  {
  char estado = Serial.read();
  delay(100);
  FuncionesTarjetas.abrir(estado);
}
  rfid.halt();
}