String status = "";
String status2= "";
String code = "";
color statusColor = color(0);
color statusColor2 = color(0);
import processing.serial.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
Serial puertoSerie;
String outFilename ="log.txt";
String temp;
int escaneando=0;
void setup()
{
  size(1024, 768);
  textAlign(CENTER,CENTER);
  textSize(30);
  //print(Serial.list());
  puertoSerie = new Serial(this, Serial.list()[1], 9600);
}
void onCardRead(int estado, String codigo,String marcaTiempo)
{
  if (estado == 1)
  {
    status = "Acceso concedido";
    statusColor = color(0, 255, 0);
  }
  else
  {
    status = "Acceso denegado";
    statusColor = color(255, 0, 0); 
  }
  code="El codigo de la tarjeta es: " + codigo;
}
void appendTextToFile(String filename, String text) // Funcion para escribir en un archivo y crearlo en caso de ser necesario
{
  File f = new File(dataPath(filename));
  if(!f.exists())
  {
    createFile(f);
  }
  try
  {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }catch (IOException e)
  {
      e.printStackTrace();
  }
}
void createFile(File f)// Funcion para crear archivo
{
  File parentDir = f.getParentFile();
  try{
    parentDir.mkdirs(); 
    f.createNewFile();
  }catch(Exception e){
    e.printStackTrace();
  }
} 
void keyPressed()
{
  if (key == '1')
  {
    status2 = "Escaneando...";
    statusColor2= color(0,255,0);
    escaneando=1;
  }
  if (key == '2')
  {
    status2 = "Escaneo terminado.";
    statusColor2= color(0,0,255);
    escaneando=0;
  }
  if(key == '3')
  {
    exit();
  }
}
void verificarAcceso(String codigo)
{
  String[] lines = loadStrings(dataPath("log.txt"));
  for (int i = 0; i < lines.length; i++)
  {
    if (codigo.equals(lines[i]))
    {
      puertoSerie.write("1");
      println("aaaa");
    }
    else
    {
      puertoSerie.write("2");
    }
  }
}
void draw()
{
  int hora = hour();
  int minuto = minute();
  int segundo = second();
  String marcaTiempo = nf(hora, 2) + ":" + nf(minuto, 2) + ":" + nf(segundo, 2);
  background(0);
  fill(255);
  text("\nPresione 1 para escanear y guardar tarjetas. \nPresione 2 para dejar de escanear. \nPresione 3 para Salir.",512,100);
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
          verificarAcceso(codigo);
          if(escaneando==1)
            {
              appendTextToFile(outFilename,codigo);
            }
          }       
      }
    }
}
