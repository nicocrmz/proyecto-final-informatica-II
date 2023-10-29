// Variables para el texto de estado
String status = "";
String status2= "";
String code = "";
color statusColor = color(0);
color statusColor2 = color(0);
PrintWriter registro;
import processing.serial.*;
Serial puertoSerie;
void setup()
{
  size(1024, 768);
  textAlign(CENTER,CENTER);
  textSize(30);
  //print(Serial.list());
  registro = createWriter("log.txt");
  puertoSerie = new Serial(this, Serial.list()[1], 9600);
}
void draw()
{
  int hora = hour();
  int minuto = minute();
  int segundo = second();
  String marcaTiempo = nf(hora, 2) + ":" + nf(minuto, 2) + ":" + nf(segundo, 2);
  background(0);
  fill(255);
  text("Acerque la tarjeta al sensor\n\nPresione 1 para autorizar una tarjeta desconocida \nPresione 2 para denegarla.\n",512,100);
  fill(statusColor);
  text(status, 512, 190);
  fill(255);
  text(code,512,230);
  fill(statusColor2);
  text(status2, 512,300);
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
          onCardRead(estado,codigo,marcaTiempo);
          }       
      }
    }
}
// Esta función se llama cuando se lee una tarjeta NFC
void onCardRead(int estado, String codigo,String marcaTiempo)
{
  // Aquí puedes agregar el código para verificar el ID de la tarjeta
  if (estado == 1)
  {
    status = "Acceso concedido";
    statusColor = color(0, 255, 0); // Verde
    registro.println("Autorizado,"+codigo+","+marcaTiempo);
  }
  else
  {
    status = "Acceso denegado";
    statusColor = color(255, 0, 0); // Rojo
    registro.println("Denegado,"+codigo+","+marcaTiempo);
  }
  code="El codigo de la tarjeta es: " + codigo;
}
void keyPressed()
{
  // Verifica si la tecla "A" ha sido presionada
  if (key == '1')
  {
    print("xs");
    puertoSerie.write("1");
    status2 = "Tarjeta autorizada";
    statusColor2= color(0,255,0);
  }
  if (key == '2')
  {
    puertoSerie.write("2");
    status2 = "Tarjeta denegada";
    statusColor2= color(255,0,0);
  }
  if(key == '3')
  {
    registro.close();
    exit();
  }
}
