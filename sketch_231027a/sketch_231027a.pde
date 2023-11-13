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
int separacion =30;
float offsetY;
int tamano = 100;
int[] estadosBotones = new int[4];
color[][] colores;
int escaneando=0;
int autorizado=0;
int ultimoBotonPresionado = -1;
String sector="";
PFont Fuente;
PImage fondo;
void setup()
{
  background(0);
  size(800, 600);
  textAlign(CENTER,CENTER);
  fondo = loadImage("Ground2.jpg");
  Fuente = createFont("SourceCodePro-Regular.ttf", 24);
  textFont(Fuente); 
  surface.setTitle("Control de Acceso");
  puertoSerie = new Serial(this, Serial.list()[1], 9600);
  offsetY = height / 2 + tamano /2;
   for (int i = 0; i < 4; i++)
   {
    estadosBotones[i] = 0;
   }
  colores = new color[4][4];
  for (int fila = 0; fila < 4; fila++)
  {
    for (int columna = 0; columna < 4; columna++)
    {
      colores[fila][columna] = color(255, 0, 0); 
    }
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
    statusColor2= color(255,255,0);
    escaneando=0;
  }
  if(key == '3')
  {
    exit();
  }
}
void draw()
{
  background(0);
  image(fondo, 0, height / 2, width, height / 2); 
  fill(5, 90, 247);
  rect(0,0,800,40);
  fill(255);
  text("Funciones Principales:",400,17);
  fill(255);
  rect(0,40,800,100);
  fill(5, 90, 247);
  rect(0,140,800,40);
  fill(255);
  text("Estados:", 400,160);
  fill(13, 9, 125);
  rect(0,180,800,80);
  fill(5, 90, 247);
  rect(0,260,800,40);
  fill(255);
  text("Sectores:",400,280);
  fill(0);
  text("\nPresione 1 para escanear y guardar tarjetas. \nPresione 2 para dejar de escanear. \nPresione 3 para Salir.",400,75);
  fill(statusColor);
  text(status, 400, 200);
  fill(255);
  text(code,400,180);
  fill(statusColor2);
  text(status2, 400,300);
  fill(0,255,0);
  text(sector, 400, 240);
  if (puertoSerie.available() > 0)
  {
    String datos = puertoSerie.readStringUntil('\n');
    if(autorizado==1)
    {
      serialEvent(datos);
      println(datos);
    }
      if (datos !=null)
      {
         String[] estados = split(datos,',');
        if (estados[0].length()>7)
          {
          String codigo = (trim(estados[0]));
          println(codigo);
          verificarAcceso(codigo);
          if(escaneando==1)
            {
              appendTextToFile(outFilename,codigo);
            }
          }       
      }
    }
  float centroX = width / 2 - (2 * tamano + separacion) / 2;
  for (int fila = 0; fila < 2; fila++)
  {
    for (int columna = 0; columna < 2; columna++)
    {
      float x = centroX + columna * (tamano + separacion);
      float y = offsetY + fila * (tamano + separacion);
    fill(colores[fila][columna],99);
    rect(x, y, tamano, tamano,20);
    }
  }
  if (ultimoBotonPresionado != -1)
  {
    sector =("Sector " + (ultimoBotonPresionado + 1));
    if(autorizado==0)
    {
      sector="";
    }
  }
}
void appendTextToFile(String filename, String text)
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
void createFile(File f)
{
  File parentDir = f.getParentFile();
  try{
    parentDir.mkdirs(); 
    f.createNewFile();
  }catch(Exception e){
    e.printStackTrace();
  }
} 
void verificarAcceso(String codigo)
{
  int encontrado =0;
  String[] lines = loadStrings(dataPath("log.txt"));
  for (int i = 0; i < lines.length; i++)
  {
    if (codigo.equals(lines[i]))
    {
      puertoSerie.write("1");
      encontrado=1;
      autorizado=1;
      status = "Acceso autorizado, Seleccione el sector...";
      statusColor = color(0, 255, 0);
      break;
    }
  }
  if (encontrado ==0)
  {
    puertoSerie.write("2");
    autorizado=0;
    status = "Acceso denegado";
    statusColor = color(255, 0, 0);
    sector="";
  }
  //code="El codigo de la tarjeta es: " + codigo;
}
void serialEvent(String entrada)
{
    if (entrada !=null)
  {
    entrada = trim(entrada);
    if (entrada.length() == 4)
    {
      for (int i = 0; i < 4; i++)
      {
        int fila = i / 2;
        int columna = i % 2;
        estadosBotones[i] = int(entrada.charAt(i)) - 48;
        if (estadosBotones[i] == 1)
        {
          ultimoBotonPresionado = fila * 2 + columna;
          colores[fila][columna] = color(0, 255, 0); // Verde
          delay(2000);
        } else
        {
          colores[fila][columna] = color(255, 0, 0); // Rojo
        }
      }
    }
  }
}
