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
RFID rfid(10, 9);  //D10:SDA D9:RST 
unsigned char str[MAX_LEN]; // Variable que se utiliza para convertir el codigo de las tarjetas de binario a una cadena hexadecimal
Servo Servo1; //Declaracion del objeto de la clase servo
boolean locked = true; //Variable que almacena el estado del acceso 
String tarjetaTemporal; //Se almacena el codigo de la tarjeta escaneada             
int cerrado = 20; //posicion inicial del servo
int abierto = 88; //posicion de apertura
int ledRojo = 5; //Pin del led rojo
int ledVerde = 6; //Pin del led verde
const int boton1 = 2; // Pin del primer botón
const int boton2 = 7; // Pin del segundo botón
const int boton3 = 4; // Pin del tercer botón
const int boton4 = 8; // Pin del cuarto botón
const int pinBuzzer = A0; //Pin del buzzer
/*
Declaracion de la clase funciones y el objeto FuncionesTarjetas.
La funcion "abrir" se encarga de accionar el servo y mostrar el estado mediante los leds y el buzzer.
Se recibe el estado desde processing. Si el estado es igual a 1, quiere decir que la tarjeta esta autorizada.El led verde parpadea, suena el buzzer y se acciona el servo.
Si el estado es igual a 0, se hace parpadear el led rojo.
*/
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

/*
En el setup se inicializa el modulo RFID, los botones, los leds y la comunicacion por el puerto serie.
Se mueve el servo a la posicion de bloqueo.
*/
void setup() 
{ 
  Serial.begin(9600);    
  SPI.begin(); //Se inicia la comunicacion con el modulo rfid (Serial peripheral interface)           
  rfid.init(); //Se inicializa el modulo rfid
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
  Servo1.attach(3);    // Pin del servo      
  Servo1.write(cerrado);    //Mover el servo a la posicion de cierre
} 
/*
Se almacena el estado de los botones en las variabes "estadoBoton" y luego se envian por puerto serie a processing, cuando se presione un boton, se mostrara por pantalla en Processing, siempre que la tarjeta escaneada este autorizada.
El modulo RC522 esta en funcionamiento, cuando detecte una tarjeta, almacenara el codigo de la misma en la variable "tarjetaTemporal".
Processing determina si la tarjeta esta autorizada y envia el estado a Arduino por el puerto serie.

*/
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
  if (rfid.findCard(PICC_REQIDL, str) == MI_OK)  //Si la funcion findCard devuelve MI_OK quiere decir que se encontro una tarjeta
  { 
    String temp = "";                             
    if (rfid.anticoll(str) == MI_OK)   //Se pudo identificar la tarjeta rfid encontrada
    { 
      for (int i = 0; i <= 4; i++)               
      { 
        temp = temp + (0x0F & (str[i] >> 4)); 
        temp = temp + (0x0F & str[i]); 
      } 
      tarjetaTemporal=temp;
    }
    rfid.selectTag(str); //Se selecciona la ultima tarjeta escaneada para evitar escaneos redundantes
    Serial.println(tarjetaTemporal);
  }
  if (Serial.available() > 0)
  {
  char estado = Serial.read(); //Recibe si la tarjeta esta autorizada o no desde processing
  delay(100);
  FuncionesTarjetas.abrir(estado);
}
  rfid.halt(); //Fin de la comunicacion del modulo rfid
}