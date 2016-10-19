import processing.video.*;
import netP5.*;
import oscP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

Capture video;

int camPixels;
PImage antesPixels;


//variable para guardar tiempo transcurrido
int tiempo;
//variable para guardar el tiempo de delay necesario
int delay = 1000;

/*
PImage fondo;
PImage [] animacion1 = new PImage [3];
PImage [] animacion2 = new PImage [3];
PImage [] animacion3 = new PImage [3];
*/

ArrayList<panadero> flores;
int cuantas = 150;
int rotacion = 0;

void setup() {
  size(1280, 720, P3D);
  hint(ENABLE_DEPTH_SORT);
   
  String[] cameras = Capture.list();
  printArray(cameras);
  
  //Empezar la captura
  video = new Capture(this, width, height);
  
  //Capturar imágenes de la cámara
  video.start();
  
  camPixels = video.width * video.height;
  // Almacenar la imagen anterior (el fondo) en un array
  antesPixels = new PImage (video.width, video.height);
  // Cargar los pixeles para poder manipularlos
  loadPixels();
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  /* myRemoteLocation is a NetAddress (takes 2 parameters, an ip address and a port number) and is used as parameter in oscP5.send()*/
  myRemoteLocation = new NetAddress("127.0.0.1",12001);
  
  //guardar tiempo actual
  tiempo = millis();
  
  /*
  fondo = loadImage("fondo.png");
  
  // dibujar particulas individuales para el fondo y animarlas
  
   for ( int i = 0; i<animacion1.length; i++ ) {
      animacion1[i] = loadImage( "adelante" + (i+1) + ".png" );
      }
      
  for ( int i = 0; i<animacion2.length; i++ ) {
      animacion2[i] = loadImage( "medio" + (i+1) + ".png" );
      }
      
  for ( int i = 0; i<animacion3.length; i++ ) {
      animacion3[i] = loadImage( "atras" + (i+1) + ".png" );
      }
   */   
  
  //flores = new panadero();
  flores = new ArrayList<panadero>();
  for (int i=0; i<cuantas; i++) {
    flores.add(new panadero());
  }
}

void draw() {
  background(0);
  OscMessage myOscMessage = new OscMessage("/test");
  
  // Añadir la variable (int) cuantas al osc message 
  myOscMessage.add(cuantas); 

  // Enviar el mensaje
  oscP5.send(myOscMessage, myRemoteLocation); 
  
  /*
  image(fondo, 0, 0);
  int quePan = int(random(0, 3));

  //chequear si el tiempo transcurrido - el tiempo guardado al principio es mayor al delay
  if(millis() - tiempo >= delay) {
    //dibujar imágenes
    image(animacion1[quePan], 90, 700);
    image(animacion2[quePan], 900, 850);
    image(animacion3[quePan], 1400, 830);
    //actualizar tiempo guardado
    tiempo = millis();
  }
  */
  
  int threshold = 350000000;
  int presenceSum = 0;
    
   if (video.available()) {
    // Leer nuevo frame de video
    video.read(); 
    // Hacer disponibles los pixels del video
    video.loadPixels(); 
    
    // Diferencia entre el frame actual y el fondo almacenado
    // Límite para comparar si el cambio entre las dos imágenes es mayor a...
    
    
    // Para cada pixel de video de la cámara, tomar el color actual y el anterior de ese pixel
    for (int i = 0; i < camPixels; i++) { 
      color currentColor = video.pixels[i];
      color backgroundColor = antesPixels.pixels[i];
      
      // Extraer los colores de los píxeles del frame actual
      int currentR = (currentColor >> 16) & 0xFF;
      int currentG = (currentColor >> 8) & 0xFF;
      int currentB = currentColor & 0xFF;
      
      // Extraer los colores de los píxeles del fondo
      int backgroundR = (backgroundColor >> 16) & 0xFF;
      int backgroundG = (backgroundColor >> 8) & 0xFF;
      int backgroundB = backgroundColor & 0xFF;
    
      // Computar la diferencia entre los colores
      int diffR = abs(currentR - backgroundR);
      int diffG = abs(currentG - backgroundG);
      int diffB = abs(currentB - backgroundB);
      
      // Sumar las diferencias a la cuenta
      presenceSum += diffR + diffG + diffB;
      
      // Renderizar la imagen diferente en la pantalla
      pixels[i] = color(diffR, diffG, diffB);
    }
    
   //Ver los pixeles del array que cambiaron y escribir la diferencia
   updatePixels();
   println(presenceSum); 
   
   //Si la diferencia es mayor al límite desaparecer las partículas.

    pushMatrix();
    translate(width/2, height/2, width/-2);
   
   for (int n=0; n<5; n++) {
      pushMatrix();
      rotateY(radians(n*(360/5)));
      pushMatrix();
      translate(width/2, 0, 0);
      rotateY(-radians(rotacion)); 
      
   for (int i = flores.size()-1; i >= 0;i--) {  
      panadero l = flores.get(i);
      pushMatrix();
      rotateY(-radians((360/5)));
      l.draw();
      popMatrix();
      
      if (presenceSum > threshold) {
      flores.remove(i);
      } 
    }
     popMatrix();
     popMatrix();
  }
  popMatrix();
  rotacion++;
   } 
   
  //Si aparece el espectador enviar con el mensaje un 1, sino un 0 
  if (presenceSum > threshold) {
   myOscMessage.add(1);
   oscP5.send(myOscMessage, myRemoteLocation);
  } 
  else {    
    myOscMessage.add(0);
    oscP5.send(myOscMessage, myRemoteLocation);
  }
  
}





/*
 In addition, when deleting elements in order to hit all elements, 
 you should loop through it backwards, as shown here:
for (int i = particles.size() - 1; i >= 0; i--) {
  Particle part = particles.get(i);
  if (part.finished()) {
    particles.remove(i);
  }
}
*/


/*
// Al presionar una tecla capturar la imagen del fondo en la imagen antesPixels, copiar cada pixel de los frames en ella
void keyPressed() {
 
  video.loadPixels();
  antesPixels.copy(video, 0, 0, video.width, video.height, 
        0, 0, video.width, video.height);
}
*/

/*
void oscEvent(OscMessage theOscMessage) {

if(theOscMessage.checkAddrPattern("/first")==true) {
if(theOscMessage.checkTypetag("i")) {

int firstValue = theOscMessage.get(0).intValue(); 
println(" values: "+firstValue);
return;
} 
} 
}
*/