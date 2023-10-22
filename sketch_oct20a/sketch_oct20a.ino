#include <SPI.h> 
#include <RFID.h>
#include <Servo.h> 
/*
1-comunicacion entre arduino y pc (hecho)
2-interfaz grafica en processing 
3-lecturas de sensores o actuadores (hecho)
4-indicar estado mediante leds (hecho)
5-maquina de estados en arduino y processing 
6-crear una clase (hecho)
7-archivos modo append
8-manejo en memoria de datos
*/
RFID rfid(10, 9);       //D10:SDA D9:RST 
unsigned char status; 
unsigned char str[MAX_LEN];

String tarjetasAutorizadas [2] = {"0", "19612012715"};  //codigos de las tarjetas autorizadas
int tarjetasAutorizadasSize = 2;
String tarjetaTemporal;                               //Se almacena el codigo de la tarjeta escaneada

Servo Servo1;              
int cerrado = 15;               //posicion inicial del servo
int abierto = 75;             //posicion de apertura
boolean locked = true;

int ledRojo = 5;
int ledVerde = 6;

//declaracion de la clase que contiene las funciones relacionadas con las tarjetas
class Funciones
{
  public:
  void agregartarjeta(String tarjetaTemporal, char opcion) //funcion para decidir si autorizar o eliminar una tarjeta escaneada
  {
  if (opcion == '1') // si se escribe '1' por teclado se autoriza la tarjeta
    {
      tarjetasAutorizadas[1]=tarjetaTemporal;
      Serial.println("Tarjeta autorizada");
    }
    if (opcion == '2') // si se escribe '2' se elimina
    {
      tarjetasAutorizadas[1]='0';
      Serial.println("Tarjeta eliminada");
    } 
  }

  void Verificar (String temp)    //Funcion para verificar si la tarjeta escaneada esta autorizada
{
  boolean granted = false;
  for (int i=0; i <= (tarjetasAutorizadasSize-1); i++)    // se recorre todo el arreglo donde se almacenan los codigos 
  {
    if(tarjetasAutorizadas[i] == temp)      //si el codigo autorizado coincide con la tarjeta escaneada      
    {
      Serial.println ("Acceso autorizado");
      granted = true;
      if (locked == true)         //abrir si esta cerrado
      {
          Servo1.write(abierto);
          locked = false;
      }
      else if (locked == false)   //cerrar si esta abierto
      {
          Servo1.write(cerrado);
          locked = true;
      }
      digitalWrite(ledVerde, HIGH);    //secuencia para el led verde
      delay(200);
      digitalWrite(ledVerde, LOW);
      delay(200);
      digitalWrite(ledVerde, HIGH);
      delay(200);
      digitalWrite(ledVerde, LOW);
      delay(200);
    }
  }
  if (granted == false)     //Si la tarjeta no coincide
  {
    Serial.println ("Acceso denegado");
    digitalWrite(ledRojo, HIGH);      //secuencia para el led rojo
    delay(200);
    digitalWrite(ledRojo, LOW);
    delay(200);
    digitalWrite(ledRojo, HIGH);
    delay(200);
    digitalWrite(ledRojo, LOW);
    delay(200);
  }
  Serial.println("Presione 1 para autorizar esta tarjeta, 2 para eliminarla");
}
};
Funciones FuncionesTarjetas;

/////
void setup() 
{ 
  Serial.begin(9600);    
  SPI.begin();           
  rfid.init();          
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
  Serial.println("Coloque la tarjeta cerca del sensor...");
} 

void loop() 
{ 
  if (rfid.findCard(PICC_REQIDL, str) == MI_OK)   //se espera a que se acerque una tarjeta
  { 
    Serial.println("Tarjeta encontrada"); 
    String temp = "";                             //Se almacena el codigo de la tarjetatemporalmente
    if (rfid.anticoll(str) == MI_OK)              //Deteccion anti colisiones
    { 
      Serial.print("El numero de serie de la tarjeta es : "); 
      for (int i = 0; i <= 4; i++)                 //se muestra el codigo por el monitor serie 
      { 
        temp = temp + (0x0F & (str[i] >> 4)); 
        temp = temp + (0x0F & str[i]); 
      } 
      Serial.println (temp);
      tarjetaTemporal=temp;
      FuncionesTarjetas.Verificar (temp);     //verificar si la tarjeta esta autorizada
    } 
    rfid.selectTag(str); //
  }
  while(Serial.available()>0)
  {
    char opcion = Serial.read();
    FuncionesTarjetas.agregartarjeta(tarjetaTemporal, opcion);
  }
  rfid.halt();
}