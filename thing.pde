class thing {
    
  float x,y;
  float xv,xa;
  float yv,ya;
  float yv_dampening,xv_dampening;
  float w,h;
  float m;
  int r,g,b;
  boolean collisions;
   
  String metadata() {
    return "x,y,xv,xa,yv,ya,yv_dampening,xv_dampening,w,h,m,r,g,b,collisions";
  }
  
  String save() {
    StringBuilder sb = new StringBuilder();
    return sb.toString();
  }
  
  void update() {
    x += xv;
    y += yv;
    xv += xa;
    yv += ya;
  
    // x collision
    if(collisions) {
      if((x+w/2.0) >= width) {
        xv = -xv * xv_dampening;
        x--;
      }
      else if((x-w/2.0) <= 0) {
        xv = -xv * xv_dampening;
        x++;
      }
      
      // y collision
      if((y+h/2.0) >= height) {
        yv = -1.0*yv * yv_dampening;
        y--;
        //if(abs(yv) < 0.0000001) {
         // yv = 0;
        //}
      }
      else if((y-h/2.0) <= 0) {
        yv = -1.0*yv * yv_dampening;
        y++;
      }
    }
  }

}

