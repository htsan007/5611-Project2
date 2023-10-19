

void setup() {
  size(500, 500); //P3D for 3d? OPENGL?
  surface.setTitle("CSCI5611 Proj2 2D fluid");
  scene_scale = width / 10.0f;
  
  img = loadImage("sink.jpg");
  
  
  //-------------
  
}

// Node struct
class Node {
  Vec2 pos;
  Vec2 vel;
  Vec2 last_pos;
  float dens;
  float densN; 
  float press; 
  float pressN;
  boolean grabbed = false;
  
  Node(Vec2 pos) {
    this.pos = pos;
    this.vel = new Vec2(0, 0);
    this.last_pos = pos;
  }
}
class Pair {
  int p1_indx, p2_indx; //access nodes from plist directly, all data in one place
  float q, q2, q3; //q2 is q^2, q3 is q^3 //pair data
  
  
  Pair(int p1, int p2, float q) {
    this.p1_indx = p1;
    this.p2_indx = p2;
    this.q = q;
    this.q2 = pow(q,2);
    this.q3 = pow(q,3);
  }
}

PImage img;
float scene_scale = width / 10.0f;
float nodeR = 0.2; //node radius
//SPRING FORCE
float ksmoothRad = nodeR * 1.45;
float k_stiff = 150;
float k_stiffN = 1000;
float k_rest_density = 0.15;

Vec2 mousePos = new Vec2(mouseX/scene_scale,mouseY/scene_scale);
float grab_radius = 0.5;

// Gravity
Vec2 gravity = new Vec2(0, 7);
float cor = 0.3f;

//Node for all 20 nodes, base is indx 0
Node plist[] = new Node[750];
int numParticles = plist.length;
int totalParticles = 0; //counter for generation
//Vec3 triangleList[][] = new Vec3[][3]
//Vec3 indexList[][] = new Vec3[1152][3]; //1152 triangles, each hold 3 node positions, counterclockwise
//Vec3 base_pos1 = new Vec3(4, 4, 4);


// Scaling factor for the scene

Vec2 ballPos; //obstacle position

// Physics Parameters -- updatable steps
int relaxation_steps = 10;
int sub_steps = 10;
float genrate = 15;


void update_physics(float dt) {
  
  float genFloat =  genrate * dt;
  int genInt = int(genFloat);
  float fractPart = genFloat - genInt;
  
  if(random(1) < fractPart) {
    genInt++;
  }
  if(totalParticles < numParticles){ //generating
    for(int i = 0; i < genInt; i++){
      if (totalParticles >= numParticles) {break;}
      Vec2 pos = new Vec2((4.5+random(genInt)+nodeR),(random(2.8,3.3) + nodeR));
        //Vec3 vel = new Vec3(random(-5,5), random(-5,5), random(-5,5));
        plist[totalParticles] = new Node(pos);
        totalParticles++;
    }
  }
    
  //WALL COLLISION 
  //for(int i = 0; i < plist.length; i++){
  //    //200,300 x 240,285 y 245,285 z  OUTER BOUNDS
  //    Vec2 pos = new Vec2(random(nodeR,5),random(nodeR,10));
  //    //Vec3 vel = new Vec3(random(-5,5), random(-5,5), random(-5,5));
  //    plist[i] = new Node(pos);
  //    //plist[i].vel = vel;
  //    // y = y + link_length;
    
  //}
  
  //200,300 x 240,285 y 227.5,302.5 z  OUTER BOUNDS
  //for (int i = 0; i < plist.length; i++){
  //}
  for (int i = 0; i < totalParticles; i++){
    plist[i].vel = (plist[i].pos.minus(plist[i].last_pos)).times(1/dt);
    plist[i].vel = plist[i].vel.plus(gravity.times(dt));
    
    ////gravity
    //plist[i].vel.add(gravity.times(pow(2*1.3,2)*dt));
    //plist[i].pos.add(plist[i].vel.times(dt));
    
    // Ball-Wall Collision (account for radius)
    if(plist[i].pos.x < 0){
      if(plist[i].pos.y > height/2/scene_scale){
        plist[i].pos.x = 0;
        plist[i].vel.x *= -cor;
      }
    }
    if (plist[i].pos.x > width/scene_scale){
      if(plist[i].pos.y > height/2/scene_scale){
        plist[i].pos.x = width/scene_scale ;
        plist[i].vel.x *= -cor;
      }
    }
    //if (plist[i].pos.y < 0 ){ //NO CEILING
    //  plist[i].pos.y = 0;
    //  plist[i].vel.y *= -cor;
    //}
    if (plist[i].pos.y > height/scene_scale ){
      plist[i].pos.y = height/scene_scale ;
      plist[i].vel.y *= -cor;
    }
    
    if(plist[i].grabbed){
      mousePos = new Vec2(mouseX/scene_scale,mouseY/scene_scale);
      plist[i].vel = plist[i].vel.plus( (((mousePos.minus(plist[i].pos)).times(1/grab_radius)).minus(plist[i].vel)).times(20*dt));
    }
    
    plist[i].last_pos = plist[i].pos;
    plist[i].pos = plist[i].pos.plus(plist[i].vel.times(dt));
    plist[i].dens = 0;
    plist[i].densN = 0;
   }
    Pair pairs[] = new Pair[numParticles*numParticles];
    int count = 0;
    //CHECK PARTICLE PAIRS NOW --------------------
    for(int i = 0; i < totalParticles; i++) {
      for(int j = 0; j < totalParticles; j++){
        float dist = plist[i].pos.distanceTo(plist[j].pos);
        if((dist < ksmoothRad) && (i < j)){
          float q = 1 - (dist/ksmoothRad);
          pairs[count] = new Pair(i, j, q); //new particle pair
          count++;
        }
       }
     }
     for(int i = 0; i < count; i++){ //go through pairs, per particle density
       plist[pairs[i].p1_indx].dens += pairs[i].q2;
       plist[pairs[i].p2_indx].dens += pairs[i].q2;
       plist[pairs[i].p1_indx].densN += pairs[i].q3;
       plist[pairs[i].p2_indx].densN += pairs[i].q3;
     }
     for(int i = 0; i < totalParticles; i++){ 
       plist[i].press = k_stiff * (plist[i].dens - k_rest_density);
       plist[i].pressN = k_stiffN * (plist[i].densN);
       if(plist[i].press > 30){ plist[i].press = 30; } //max pressure
       if(plist[i].pressN > 300){ plist[i].pressN = 300; } //max near pressure
     }
     for(int i = 0; i < count; i++){
       float total_pressure = (plist[pairs[i].p1_indx].press + plist[pairs[i].p2_indx].press) * pairs[i].q
                               + (plist[pairs[i].p1_indx].pressN + plist[pairs[i].p2_indx].pressN) * pairs[i].q2;
       float displace = total_pressure * pow(dt,2);
       
       Vec2 p1p2norm = (plist[pairs[i].p1_indx].pos.minus(plist[pairs[i].p2_indx].pos)).normalized();
       //Vec3 p2p1norm = (plist[pairs[i].p2_indx].pos.minus(plist[pairs[i].p1_indx].pos)).normalized();
       plist[pairs[i].p1_indx].pos = plist[pairs[i].p1_indx].pos.plus(p1p2norm.times(displace));
       plist[pairs[i].p2_indx].pos = plist[pairs[i].p2_indx].pos.plus(p1p2norm.times(-displace));
     }
}

boolean paused = true; //start paused

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
}
void mousePressed() {
  mousePos = new Vec2(mouseX/scene_scale,mouseY/scene_scale);
  for(int i = 0 ; i < totalParticles; i++){
    if(mousePos.distanceTo(plist[i].pos) < grab_radius){
      plist[i].grabbed = true;
    }
    
  }
}
void mouseReleased(){
  for(int i = 0 ; i < totalParticles; i++){
    plist[i].grabbed = false;
  }
}

//float time = 0;
void draw() {
  float dt = 1.0 / 20; //Dynamic dt: 1/frameRate; //0.05 dt do NOT change
  scene_scale = width / 10.0f;
    if (!paused) {
      for (int i = 0; i < sub_steps; i++) {
        //time += dt / sub_steps;
        update_physics(dt / sub_steps);
      }
    }
    //cam debugging
    //println(camera.position);
    //println(camera.theta);
    //println(camera.phi);
    
    background(img);
    
    // Draw Nodes (green)
    fill(0, 200, 0);
    stroke(1);
    strokeWeight(1);
    
    for(int i = 0; i < totalParticles; i++){
      //pushMatrix();
      float norm_q = (plist[i].press) / 35;
      fill(255*(0.7 - norm_q*0.5),255*(0.85 - norm_q*0.4), 255*(1 - norm_q*0.2)); //white to blue gradient
      ellipse(plist[i].pos.x*scene_scale,plist[i].pos.y*scene_scale, nodeR*scene_scale, nodeR*scene_scale); //(250, 265, 265)
      //sphere(nodeR); //DRAWS FROM CENTER //200,300 x 240,285 y 227.5,302.5 z  OUTER BOUNDS
      //popMatrix();
        
    }
    //}
    stroke(255,255,255);
    strokeWeight(10);
    line(width,height/2,width,height); //right
    line(0,height/2,0,height); //left
    line(0,height,width,height); //bot
    //box(100,50,40); //DRAWS FROM CENTER //200,300 x 240,285 y 227.5,302.5 z  OUTER BOUNDS
    //popMatrix();
    
}


//---------------
//Vec 3 Library
//---------------

//3DVector library
public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ "," + y +")";
  }
  
  public float length(){
    if((x==0) && (y==0)){
      return 0;
    }
    else {
      return sqrt(x*x+y*y);
    }
  }
  
  public float lengthSqr(){
    return x*x + y*y;
  }
  
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x-rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void clampToLength(float maxL){
    if((x==0) && (y==0)){
     return;
    }
    float magnitude = sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }

  }
  
  
  public void setToLength(float newL){
    if((x==0) && (y==0)){
     return;
    }
    float magnitude = sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
  public void normalize(){
    if((x == 0) && (y == 0)){
      return;
    }
    else {
      float magnitude = sqrt(x*x + y*y);
      x /= magnitude;
      y /= magnitude;
    }
  }
  
  public Vec2 normalized(){
    if((x==0) && (y==0)){
     return new Vec2(0,0);
    }
    float magnitude = sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
  }
  
  public float distanceTo(Vec2 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    if((dx == 0) && (dy == 0)){
      return 0;
    }
    return sqrt(dx*dx + dy*dy);
  }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}
float vecCross(Vec2 a, Vec2 b){
  return (a.x*b.y - a.y*b.x); //ad - bc
}
Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

Vec2 perpendicular(Vec2 a) {
  return new Vec2(-a.y, a.x);
}
