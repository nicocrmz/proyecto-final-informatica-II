import processing.serial.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
Serial puertoSerie;
String status = ""; // Variables que almacenan los textos que aparecen en pantalla
String status2= "";
String code = "";
String outFilename ="codes.txt";
String outFilename2 = "log.txt";
String sector="";
color statusColor = color(0); // color de los textos "status" y status2"
color statusColor2 = color(0);
color[][] colores; //Se almacena el color de cada uno de los sectores
int separacion =30; //Variables para controlar la posicion y el tamano de los sectores en pantalla
int tamano = 100;
int[] estadosBotones = new int[4]; //Se almacena el estado de los botones enviados desde Arduino
int escaneando=0; //Variables que se utilizan como bandera para diferentes funciones
int autorizado=0;
int ultimoBotonPresionado = -1;
float offsetY;
PFont Fuente; // Fuente del texto
PImage fondo;
void setup()
{
  background(0);
  size(800, 600);
  textAlign(CENTER,CENTER);
  fondo = loadImage("Ground2.jpg"); //Se carga la imagen de fondo
  Fuente = createFont("SourceCodePro-Regular.ttf", 24); //Se cambia la fuente
  textFont(Fuente); 
  surface.setTitle("Control de Acceso"); // Nombre de la ventana de processing
  puertoSerie = new Serial(this, Serial.list()[1], 9600); //Se abre la comunicacion por puerto serie
  offsetY = height / 2 + tamano /2; //Posicion vertical para los sectores en pantalla
   for (int i = 0; i < 4; i++)
   {
    estadosBotones[i] = 0;
   }
  colores = new color[4][4]; //Mientras el estado de los botones sea igual a cero, los sectores se dibujan con color rojo
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
  text(status2, 600,160);
  fill(0,255,0);
  text(sector, 400, 240);
  int hora = hour();
  int minuto = minute();
  int segundo = second();
  String marcaTiempo = nf(hora, 2) + ":" + nf(minuto, 2) + ":" + nf(segundo, 2);
  int dia = day();    // Día actual
  int mes = month();  // Mes actual
  int ano = year();   // Año actual
  String fechaActual = dia + "/" + mes + "/" + ano;
  if (puertoSerie.available() > 0)
  {
    String datos = puertoSerie.readStringUntil('\n'); //Se obtiene el codigo de la tarjeta y el estado de los botones por puerto serie
    if(autorizado==1)
    {
      serialEvent(datos); // Si la tarjeta ya esta autorizada, se le permite al usuario seleccionar el sector al que va a ingresar
      println(datos);
    }
      if (datos !=null)
      {
         String[] estados = split(datos,',');
        if (estados[0].length()>7)
          {
          String codigo = (trim(estados[0])); // Se separan los datos de los botones y el codigo haciendo uso de un array
          println(codigo);
          verificarAcceso(codigo,marcaTiempo,fechaActual);
          if(escaneando==1) // Si el programa esta en modo de escaneo, se llama a la funcion "appendTextToFile" para guardar las tarjetas en un archivo
            {
              appendTextToFile(outFilename,codigo);
            }
          }       
      }
    }
  float centroX = width / 2 - (2 * tamano + separacion) / 2; //Dibuja los sectores 
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
  if (ultimoBotonPresionado != -1) //Cambia de color el sector correspondiente al boton presionado
  {
    sector =("Sector " + (ultimoBotonPresionado + 1));
    if(autorizado==0)// Si no esta autorizado no se puede seleccionar el sector
    {
      sector="";
    }
  }
}
void appendTextToFile(String filename, String text)
{
  File f = new File(dataPath(filename)); //Se crea un objeto file y se obtiene la ruta de acceso al archivo con el nombre especificado
  if(!f.exists())
  {
    createFile(f);//Si el archivo no existe se crea uno
  }
  try
  {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));//Se crea un printwriter para guardar el texto que se va a escribir el archivo
    out.println(text); //Se escribe el archivo
    out.close();//Cierra el printwriter
  }catch (IOException e) //Si hay algun error durante la escritura del archivo se captura y se muestra por pantalla
  {
      e.printStackTrace();
  }
}
void createFile(File f) 
{
  File parentDir = f.getParentFile(); //Directorio padre del archivo
  try{
    parentDir.mkdirs(); //crea el directorio si no existe
    f.createNewFile(); //crea un archivo en la ruta especificada
  }catch(Exception e) //Si hay algun error se muestra por pantalla
  {
    e.printStackTrace();
  }
} 
void verificarAcceso(String codigo,String tiempo,String fecha)
{
  int encontrado =0;
  String[] lines = loadStrings(dataPath("codes.txt")); 
  for (int i = 0; i < lines.length; i++)
  {
    if (codigo.equals(lines[i]))
    {
      puertoSerie.write("1");
      encontrado=1;
      autorizado=1;
      status = "Acceso autorizado, Seleccione el sector...";
      String registro= codigo+"-"+fecha+"-"+tiempo;
      appendTextToFile(outFilename2, registro);
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
}
void serialEvent(String entrada)
{
    if (entrada !=null) //Recibe el estado de los botones
  {
    entrada = trim(entrada);
    if (entrada.length() == 4)
    {
      for (int i = 0; i < 4; i++)
      {
        int fila = i / 2; //Se calculan las filas y columnas 
        int columna = i % 2; //resto
        estadosBotones[i] = int(entrada.charAt(i)) - 48; //Convierte el carácter actual de la entrada en un número entero y lo almacena en el array
        if (estadosBotones[i] == 1)
        {
          ultimoBotonPresionado = fila * 2 + columna; //Se calcula el indice del boton presionado
          colores[fila][columna] = color(0, 255, 0); // Verde
          delay(1000);
        } else
        {
          colores[fila][columna] = color(255, 0, 0); // Rojo
        }
      }
    }
  }
}
