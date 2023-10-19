

void setup() {
  size(500, 500, P3D);
  surface.setTitle("CSCI5611 Proj2 3D cloth");
  scene_scale = width / 10.0f;
  ballPos = new Vec3(5.3* scene_scale, 5.5* scene_scale, 5.5* scene_scale); //obstacle position

  flag = loadImage("flag.jpg");
  camera = new Camera();
  camera.position.x = 16.33; //Set cam position NO TOUCH
  camera.position.y = 248.9;
  camera.position.z = 270.2;
  camera.phi = -0.08;
  camera.theta = -183.6;
  camera.Update(1);
  //50 by 50
  float x = 4;
  float z = 4;
  float y = 4;
  for(int i = 0; i < 50; i++){
    z = 4;
    for(int j = 0; j < 50; j++){
      
      Vec3 pos = new Vec3(x,y, z);
      
      nodeList[i][j] = new Node(pos);
      z = z + link_length; 
    }
    x = x + link_length;
  }
}

// Node struct
class Node {
  Vec3 pos;
  Vec3 vel;
  Vec3 last_pos;

  Node(Vec3 pos) {
    this.pos = pos;
    this.vel = new Vec3(0, 0, 0);
    this.last_pos = pos;
  }
}
//SPRING FORCE
float ks = 10000;
float kd = 120; //DAMPENING FACTOR
// Link length
float link_length = 0.05;

//Node for all 20 nodes, base is indx 0
Node nodeList[][] = new Node[50][50];

// Gravity
Vec3 gravity = new Vec3(0, 0.012, 0);

PImage flag;
//Camera
Camera camera;

// Scaling factor for the scene
float scene_scale = width / 10.0f;

Vec3 ballPos; //obstacle position

// Physics Parameters -- updatable steps
int sub_steps = 10;

void update_physics(float dt) {
  
  Vec3 newVels[][] = new Vec3[50][50];
  Vec3 e;
  float l,v1,v2,f;
 
  for(int i = 0; i < nodeList[0].length; i++){ //fill new velocity buffer
    for(int j = 0; j < nodeList[0].length; j ++){
      newVels[i][j] = nodeList[i][j].vel;
    }
  }
  for(int i = 0; i < nodeList[0].length-1; i++){ //horizontal
    for(int j = 0; j < nodeList[0].length; j ++){
      e = nodeList[i+1][j].pos.minus(nodeList[i][j].pos);
      l = sqrt(dot(e,e));
      e.normalize();
      v1 = dot(e,nodeList[i][j].vel);
      v2 = dot(e,nodeList[i+1][j].vel);
      f = -ks * (link_length- l) - kd *(v1-v2);
      newVels[i][j].add(e.times(f*dt));
      newVels[i+1][j].subtract(e.times(f*dt));
    }
  }
  for(int i = 0; i < nodeList[0].length; i++){ //vertical
    for(int j = 0; j < nodeList[0].length-1; j ++){
      e = nodeList[i][j+1].pos.minus(nodeList[i][j].pos);
      l = sqrt(dot(e,e));
      e.normalize();
      v1 = dot(e,nodeList[i][j].vel);
      v2 = dot(e,nodeList[i][j+1].vel);
      f = -ks * (link_length - l) - kd *(v1-v2);
      newVels[i][j].add(e.times(f*dt));
      newVels[i][j+1].subtract(e.times(f*dt));
    
    }
  }
  for(int i = 0; i < nodeList[0].length; i++){ // add gravity, set top vel to 0
    for(int j = 0; j < nodeList[0].length; j ++){
      newVels[i][j].add(gravity);
      if(j == 0){
         newVels[i][j] = new Vec3(0,0,0); //top row vel 0
      }
      nodeList[i][j].vel = newVels[i][j]; //update vels
      nodeList[i][j].pos.add(nodeList[i][j].vel.times(dt)); //update pos
    }
  }
  
  //collision with red ball
  
  for( int i = 0; i < nodeList[0].length; i++){
    for( int j = 0; j < nodeList[0].length; j++){
      Vec3 scaledPos = new Vec3(nodeList[i][j].pos.x*scene_scale, nodeList[i][j].pos.y*scene_scale, nodeList[i][j].pos.z*scene_scale);
      float distTo = ballPos.distanceTo(scaledPos);
      //println(distTo);
      if(distTo < (0.05*scene_scale) + (0.4*scene_scale)){ //dist < node radius + ball radius
        //println("hit");
        Vec3 norm = (ballPos.minus(scaledPos).times(-1));
        norm.normalize();
        Vec3 bounce = norm.times(dot(nodeList[i][j].vel,norm));
        nodeList[i][j].vel.subtract(bounce.times(1.5));
        scaledPos.add(norm.times(0.05*scene_scale + 0.4*scene_scale - distTo));
        nodeList[i][j].pos = new Vec3(scaledPos.x/scene_scale,scaledPos.y/scene_scale,scaledPos.z/scene_scale);
      }
    }
   
  }
}

boolean paused = true; //start paused

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
  camera.HandleKeyPressed();
}

void keyReleased() {
  camera.HandleKeyReleased();
}

float time = 0;
void draw() {
  float dt = 1.0 / 20; //Dynamic dt: 1/frameRate; //0.05 dt do NOT change
  
    if (!paused) {
      for (int i = 0; i < sub_steps; i++) {
        time += dt / sub_steps;
        update_physics(dt / sub_steps);
        camera.Update(dt/sub_steps);
      }
    }
    
    background(255);
    lights();
    
    //draw red obstacle ball
    
    noStroke();
    fill(255,0,0);
    pushMatrix();
    translate(ballPos.x, ballPos.y, ballPos.z);
    sphere(0.4*scene_scale);
    popMatrix();
    
    fill(255,255,255);
    noStroke();
    noTint();
    textureMode(NORMAL);
    
    for(int i = 0; i < nodeList[0].length-1; i++){
      for(int j = 0; j < nodeList[0].length-1; j++){
        beginShape();
        texture(flag);
        vertex(nodeList[i][j].pos.x * scene_scale,nodeList[i][j].pos.y * scene_scale,nodeList[i][j].pos.z * scene_scale, //top tri
          float(i)/float(nodeList[0].length-1), float(j)/float(nodeList[0].length-1));
        vertex(nodeList[i][j+1].pos.x * scene_scale,nodeList[i][j+1].pos.y * scene_scale,nodeList[i][j+1].pos.z * scene_scale,
          float(i)/float(nodeList[0].length-1), float(j+1)/float(nodeList[0].length-1));
        vertex(nodeList[i+1][j].pos.x * scene_scale,nodeList[i+1][j].pos.y * scene_scale,nodeList[i+1][j].pos.z * scene_scale,
          float(i+1)/float(nodeList[0].length-1), float(j)/float(nodeList[0].length-1));
        endShape();
        
        beginShape();
        texture(flag);
        vertex(nodeList[i+1][j].pos.x * scene_scale,nodeList[i+1][j].pos.y * scene_scale,nodeList[i+1][j].pos.z * scene_scale, //bottom tri
          float(i+1)/float(nodeList[0].length-1), float(j)/float(nodeList[0].length-1));
        vertex(nodeList[i+1][j+1].pos.x * scene_scale,nodeList[i+1][j+1].pos.y * scene_scale,nodeList[i+1][j+1].pos.z * scene_scale,
          float(i+1)/float(nodeList[0].length-1), float(j+1)/float(nodeList[0].length-1));
        vertex(nodeList[i][j+1].pos.x * scene_scale,nodeList[i][j+1].pos.y * scene_scale,nodeList[i][j+1].pos.z * scene_scale,
          float(i)/float(nodeList[0].length-1), float(j+1)/float(nodeList[0].length-1));
        endShape();
      }
    }
}


//---------------
//Vec 3 Library
//---------------

//3DVector library
public class Vec3 {
  public float x, y, z;
  
  public Vec3(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public String toString(){
    return "(" + x+ "," + y +")";
  }
  
  public float length(){
    if((x==0) && (y==0) && (z==0)){
      return 0;
    }
    else {
      return sqrt(x*x + y*y + z*z);
    }
  }
  
  public float lengthSqr(){
    return x*x + y*y + z*z;
  }
  
  
  public Vec3 plus(Vec3 rhs){
    return new Vec3(x+rhs.x, y+rhs.y, z+rhs.z);
  }
  
  public void add(Vec3 rhs){
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }
  
  public Vec3 minus(Vec3 rhs){
    return new Vec3(x-rhs.x, y-rhs.y, z-rhs.z);
  }
  
  public void subtract(Vec3 rhs){
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }
  
  public Vec3 times(float rhs){
    return new Vec3(x*rhs, y*rhs, z*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }
  
  public void clampToLength(float maxL){
    if((x==0) && (y==0) && (z==0)){
     return;
    }
    float magnitude = sqrt(x*x + y*y + z*z);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
      z *= maxL/magnitude;
    }

  }
  
  
  public void setToLength(float newL){
    if((x==0) && (y==0) && (z==0)){
     return;
    }
    float magnitude = sqrt(x*x + y*y + z*z);
    x *= newL/magnitude;
    y *= newL/magnitude;
    z *= newL/magnitude;
  }
  
  public void normalize(){
    if((x == 0) && (y == 0) && (z==0)){
      return;
    }
    else {
      float magnitude = sqrt(x*x + y*y + z*z);
      x /= magnitude;
      y /= magnitude;
      z /= magnitude;
    }
  }
  
  public Vec3 normalized(){
    if((x==0) && (y==0) && (z==0)){
     return new Vec3(0,0,0);
    }
    float magnitude = sqrt(x*x + y*y + z*z);
    return new Vec3(x/magnitude, y/magnitude , z/magnitude);
  }
  
  public float distanceTo(Vec3 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    float dz = rhs.z - z;
    if((dx == 0) && (dy == 0) && (dz == 0)){
      return 0;
    }
    return sqrt(dx*dx + dy*dy + dz*dz);
  }
}

float dot(Vec3 a, Vec3 b){
  return a.x*b.x + a.y*b.y + a.z*b.z;
}
Vec3 vecCross(Vec3 a, Vec3 b){ 
return new Vec3(a.y*b.z - a.z*b.y, -(a.x*b.z - a.z*b.x), a.x*b.y - a.y*b.x);
}
