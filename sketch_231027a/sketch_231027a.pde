// Variables para el texto de estado
String status = "";
color statusColor = color(0);
import processing.serial.*;
Serial puertoSerie;
void setup()
{
  size(800, 600); // Tamaño de la ventana
  textAlign(CENTER,CENTER);
  textSize(20);
  print(Serial.list());
  puertoSerie = new Serial(this, Serial.list()[1], 9600);
}
void draw()
{
  background(0); // Color de fondo
  // Dibuja el estado actual
  fill(statusColor);
  text(status, 400, 100);
  if (puertoSerie.available() > 0)
  {
    String datos = puertoSerie.readStringUntil('\n');
      if (datos != null)
      {
        int estado = int (trim(datos));
        onCardRead(estado);        
      }
    }
}
// Esta función se llama cuando se lee una tarjeta NFC
void onCardRead(int estado)
{
  // Aquí puedes agregar el código para verificar el ID de la tarjeta
  if (estado == 1)
  {
    status = "Acceso concedido";
    statusColor = color(0, 255, 0); // Verde
  }
  if (estado==0)
  {
    status = "Acceso denegado";
    statusColor = color(255, 0, 0); // Rojo
  }
}
