import processing.pdf.*;

void saveInitialState(String filename) {
  
  /*PrintWriter particles = createWriter(filename+".particles");
  particles.flush();
  particles.close();
  */
  
  PrintWriter universe = createWriter(filename+".universe");
  universe.println("g="+G);
  universe.println("hue=frame"+hue);
  universe.println("hueStep="+hueStep);
  universe.println("saturation="+sat);
  universe.println("brightness=360.0");
  universe.println("bgAlpha="+bgAlpha);
  universe.println("fadeinframes="+fadeinframes);
  universe.println("strokeAlpha="+strokeAlpha);
  universe.println("trailAlpha="+trailAlpha);
  universe.println("collisionDampening="+0.02);
  universe.println("collisions="+collisions);
  universe.flush();
  universe.close();
}

thing[] cloud;
thing[] initialCloudState;
int size;
PFont font;
float mouseMass = 8000;
float G;
float maxHue = 360;
float hue;
float hueStep;
float sat;
float satStep;

long framenum = 0;
int fadeinframes = 1000;

float strokeAlpha;
float trailAlpha = 0.05;
//float trailAlpha = 1.0;
float bgAlpha = 0.0;
float collisionDampening = 0.02;
boolean collisions = false;

DateFormat df = new SimpleDateFormat("yyyy-MM-dd-hh-mm-ss-SSS");

boolean first = true;

void setup() {
  
 //size(screen.width,screen.height);
 size(3072,2304);
 
 beginDraw();
 
  smooth();
  font = loadFont("Helvetica-12.vlw");
  textFont(font,12);
  
  background(0);
  colorMode(HSB,maxHue);
  
  smooth();
  strokeCap(PROJECT);
}

void beginDraw() {
  //beginRecord(PDF,"kepler-"+df.format(Calendar.getInstance().getTime())+".pdf");
  performInit();
}

void endDraw() {
    //endRecord();
}

void performInit() {
 
  framenum = 0;
  colorMode(RGB,255);
  background(0);
  colorMode(HSB,maxHue);
  
  fill(0,0,0,maxHue*bgAlpha); 
  
  size = (int)random(50,150);
  G = random(0.006,0.010); // gravitational constant
  hue = random(0.0,maxHue);
  hueStep = random(0.001,0.09);
  
  /**
  sat = random(0.0,maxHue);
  satStep = random(0.001,0.09);
  **/
  sat = 360.0;
  satStep = 0.00000;
  
  cloud = new thing[size];
  
  float centerX = 0;
  float centerY = 0;
  
  for(int i = 0; i < cloud.length; i++) {
    
    if(i%(cloud.length/10) == 0) {
      /*
      int quadrant = (int)random(0,4);
      if(quadrant == 0) {
        // top
        centerX = random(-200,width+200);
        centerY = -200;
      }
      else if(quadrant == 1) {
        // right
        centerX = width+200;
        centerY = random(-200,height+200);
      }
      else if(quadrant == 2) {
        // bottom
        centerX = random(-200,width+200);
        centerY = 200;
      }
      else if(quadrant == 3) {
        // left
        centerX = -200;
        centerY = random(-200,height+200);
      }
      */
      
      centerX = random(-width/5,width*1.20);
      centerY = random(-height/5,height*1.20);
    }
    
    cloud[i] = new thing();
    cloud[i].collisions = collisions;
    
    float angle = random(0,TWO_PI);
    float distFromCenter = random(5,100);
    cloud[i].x = centerX + cos(angle)*distFromCenter;
    cloud[i].y = centerY + sin(angle)*distFromCenter;
    
//    cloud[i].x = random(0.0,width);
//    cloud[i].y = random(0.0,height);
    
    cloud[i].xv = 0.0;
    cloud[i].yv = 0.0;
    cloud[i].xa = 0.0;
    cloud[i].ya = 0.0;
    cloud[i].xv_dampening = collisionDampening;
    cloud[i].yv_dampening = collisionDampening;
    
    if(i%10 == 0) {
      cloud[i].m = random(10000,15000);
      cloud[i].w = 2;
      cloud[i].h = cloud[i].w;
    }
    else {
      cloud[i].m = random(1,1000);//6*noise(i*2);
      cloud[i].w = 2;
      cloud[i].h = cloud[i].w;
    }
  }
  
  // get copy of initial state to write out later
  thing[] initialStateCloud = new thing[cloud.length];
  for(int i = 0; i < cloud.length; i++) {
    //initialStateCloud[i] = cloud[i].copyme();
  }
}

void draw() {
  update();
  smooth();
  
  noStroke();
  rect(0,0,screen.width,screen.height);
  
  stroke(hue,sat,maxHue,strokeAlpha);
  for(int i = 0; i < cloud.length; i++) {
    strokeWeight(cloud[i].w);
    line(cloud[i].x,cloud[i].y,cloud[i].x-cloud[i].xv,cloud[i].y-cloud[i].yv);
  }


  String filename = "kepler-"+df.format(Calendar.getInstance().getTime());  
  if(framenum % 12000 == 0) {
    saveFrame(filename);
    saveInitialState(filename);
    endDraw();
    beginDraw();
  }
  else if(framenum % 6000 == 0) {
    saveFrame("kepler-"+df.format(Calendar.getInstance().getTime()));
  }
}

void update() {
  
  hue += hueStep;
  if(hue >= maxHue) {
    hue = 0.0;
  }
  
  sat += satStep;
  if(sat >= maxHue) {
    satStep = -satStep;
  }
  if(sat < 50) {
    satStep = -satStep;
  }
  
  strokeAlpha = maxHue * trailAlpha;
  
  if(framenum < fadeinframes) {
    strokeAlpha *= (float)framenum/(float)fadeinframes;
  }
  
  framenum++;
  
  for(int i = 0; i < cloud.length; i++) {
    cloud[i].xa = 0.0;
    cloud[i].ya = 0.0;
    
    //uncomment to have objects revolve around mouse
    /*
    float distance = dist(mouseX,mouseY,cloud[i].x,cloud[i].y);
    float force = gforce(mouseMass,cloud[i].m,distance);
    float theta = atan2(cloud[i].y-mouseY,cloud[i].x-mouseX);
    //text(theta*180/PI+"˚ / "+theta,cloud[i].x,cloud[i].y);
    float xforce = force * cos(theta);
    float yforce = force * sin(theta);

    if(mouseX > cloud[i].x) {
      xforce = abs(xforce);
    }
    else {
      xforce = -abs(xforce);
    }
    
    if(mouseY > cloud[i].y) {
      yforce = abs(yforce);
    }
    else {
      yforce = -abs(yforce);
    }
  
    cloud[i].xa = xforce/cloud[i].m;
    cloud[i].ya = yforce/cloud[i].m;
    */
    
  }
  
  for(int i = 0; i < cloud.length; i++) {
    for(int j = 0; j < cloud.length; j++) {
      if(i <= j) {
        continue;
      }
      
      float distance = dist(cloud[j].x,mouseY,cloud[i].x,cloud[i].y);
      float force = gforce(cloud[j].m,cloud[i].m,distance);
      float theta = atan2(cloud[i].y-cloud[j].y,cloud[i].x-cloud[j].x);
      float xforce = force * cos(theta);
      float yforce = force * sin(theta);
  
      if(cloud[j].x > cloud[i].x) {
        xforce = abs(xforce);
      }
      else {
        xforce = -abs(xforce);
      }
      
      if(cloud[j].y > cloud[i].y) {
        yforce = abs(yforce);
      }
      else {
        yforce = -abs(yforce);
      }
    
      cloud[i].xa += xforce/cloud[i].m;
      cloud[i].ya += yforce/cloud[i].m;
      cloud[j].xa -= xforce/cloud[j].m;
      cloud[j].ya -= yforce/cloud[j].m;

    }
  }
  
  for(int i = 0; i < cloud.length; i++) {
    cloud[i].update();
  }
}

float gforce(float m1, float m2, float r) {
  return G*(m1*m2)/pow(r+15,2);//(r+15)/2,2);
}

void keyPressed() {
  if(key == 'c') {
    endDraw();
    beginDraw();
  }
}


