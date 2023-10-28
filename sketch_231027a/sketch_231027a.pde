// Variables para el texto de estado
String status = "";
String code = "";
color statusColor = color(0);
import processing.serial.*;
Serial puertoSerie;
void setup()
{
  size(800, 600); // Tamaño de la ventana
  textAlign(CENTER,CENTER);
  textSize(30);
  print(Serial.list());
  puertoSerie = new Serial(this, Serial.list()[1], 9600);
}
void draw()
{
  background(0); // Color de fondo
  // Dibuja el estado actual
  fill(255);
  text("Acerque la tarjeta al sensor\n\nPresione 1 para autorizar una tarjeta desconocida \nPresione 2 para denegarla.\n",400,100);
  fill(statusColor);
  text(status, 400, 190);
  fill(255);
  text(code,400,230);
  if (puertoSerie.available() > 0)
  {
    String datos = puertoSerie.readStringUntil('\n');
      if (datos != null)
      {
         String[] estados = split(datos,',');
        if (estados.length !=0)
          {
          int estado = int(trim(estados[0]));
          String codigo = (trim(estados[1]));
          onCardRead(estado,codigo);
          }       
      }
    }
}
// Esta función se llama cuando se lee una tarjeta NFC
void onCardRead(int estado, String codigo)
{
  // Aquí puedes agregar el código para verificar el ID de la tarjeta
  if (estado == 1)
  {
    status = "Acceso concedido";
    statusColor = color(0, 255, 0); // Verde
  }
  else
  {
    status = "Acceso denegado";
    statusColor = color(255, 0, 0); // Rojo
  }
  code="El codigo de la tarjeta es: " + codigo;
}
