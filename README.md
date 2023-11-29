# proyecto-final-informatica-II
El objetivo del proyecto es controlar el acceso a un edificio y 4 diferentes sectores mediante el uso de tarjetas RFID, el módulo RC522 y botones físicos.

Arduino se encarga de escanear las tarjetas, obtener el código, accionar el servo motor y mostrar los estados mediante leds y buzzer.

Para el control del módulo RC522 se utilizan las librerías SPI.h y RFID.h.
Para controlar el servomotor se utiliza la librería Servo.h.

Cuando el programa está en funcionamiento, el módulo se encarga de detectar si se acerca alguna tarjeta RFID al sensor. Cuando el sensor detecta a una tarjeta, se obtiene el código de la tarjeta escaneada y se envía a Processing por el puerto serie.

Si la tarjeta está autorizada, el buzzer emite sonido y se enciende un led verde.
Si no está autorizada se enciende el led rojo.

Processing tiene 2 funciones:
-Escaneo y registro de tarjetas autorizadas mediante archivos: Cuando se presiona 1 en el teclado, Processing crea un archivo “log.txt” y escribe los códigos de las tarjetas que se escaneen mientras esta función esté activa. Cuando se presiona 2 en el teclado, se guarda el archivo y esta función se detiene.

-Verificar si las tarjetas están autorizadas: Cuando se escanea una tarjeta, processing se encarga de consultar el archivo “log.txt” creado anteriormente para verificar que la tarjeta está autorizada, si la tarjeta está autorizada, se envía dicho estado a arduino por el puerto serie, se acciona el servo y se le pide al usuario que presione el botón físico correspondiente al sector al que desea ingresar.

Se muestra un mensaje por pantalla indicando si la tarjeta está autorizada o no.
