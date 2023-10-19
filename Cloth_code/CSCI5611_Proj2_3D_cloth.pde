

void setup() {
  size(500, 500, P3D); //P3D for 3d? OPENGL?
  surface.setTitle("CSCI5611 Proj2 3D cloth");
  scene_scale = width / 10.0f;
  //nodeList[0][0] = new Node(base_pos1); //base
  //for(int i = 1; i < nodeList.length; i++){
  //  Vec3 pos = new Vec3(5+i*0.2,5, 5);
  //  nodeList[i] = new Node(pos);
  //}
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
      // y = y + link_length;
      z = z + link_length; //try offset to see side view - delete when camera implemented
    }
    //z = z + link_length;
    x = x + link_length;
  }
  //-------------
  total_dev = 0;
  //output = createWriter("best_data.txt"); //update for each output file -see hw desc ---------------------
  //------------
  start_sec = 0;
  end_sec = 0;
  total_sec = 0;
  
  start_sec = millis();
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
//Vec3 triangleList[][] = new Vec3[][3]
//Vec3 indexList[][] = new Vec3[1152][3]; //1152 triangles, each hold 3 node positions, counterclockwise
//Vec3 base_pos1 = new Vec3(4, 4, 4);

// Gravity
Vec3 gravity = new Vec3(0, 0.012, 0);

PImage flag;
//Camera
Camera camera;

// Scaling factor for the scene
float scene_scale = width / 10.0f;

Vec3 ballPos; //obstacle position

// Physics Parameters -- updatable steps
int relaxation_steps = 10;
int sub_steps = 10;


float total_dev = 0;
float total_energy = 0;
float start_sec = 0;
float end_sec = 0;
float total_sec = 0;

PrintWriter output; //out file for data

void update_physics(float dt) {
  // Semi-implicit Integration
  //for(int i = 0; i < nodeList.length; i++){
    
  //   nodeList[i].last_pos = nodeList[i].pos;
  //   nodeList[i].vel = nodeList[i].vel.plus(gravity.times(dt));
  //   nodeList[i].pos = nodeList[i].pos.plus(nodeList[i].vel.times(dt));
  
  //}

  // Constrain the distance between nodes to the link length
  //for (int i = 0; i < relaxation_steps; i++) {
  //  for(int j = 1; j < nodeList.length; j++){
  //    Vec3 delta = nodeList[j].pos.minus(nodeList[j-1].pos);
  //    float delta_len = delta.length();
  //    float correction = delta_len - link_length;
      
  //    Vec3 delta_normalized = delta.normalized();
  //    nodeList[j].pos = nodeList[j].pos.minus(delta_normalized.times(correction / 2));
  //    nodeList[j-1].pos = nodeList[j-1].pos.plus(delta_normalized.times(correction / 2));
  //  }
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
  for(int i = 0; i < nodeList[0].length; i++){ //fill new velocity buffer, add gravity, set top vel to 0
    for(int j = 0; j < nodeList[0].length; j ++){
      newVels[i][j].add(gravity);
      if(j == 0){
         newVels[i][j] = new Vec3(0,0,0); //top row vel 0
      }
      nodeList[i][j].vel = newVels[i][j]; //update vels
      nodeList[i][j].pos.add(nodeList[i][j].vel.times(dt)); //update pos
    }
  }
    
  //for(int i = 0; i < nodeList[0].length; i++){ 
  //  for(int j = 0; j < nodeList[0].length; j ++){
  //    //if(j == 0){
  //    //   nodeList[i][j].pos = new Vec3(4 + (0.1*i) , 4, 4); //pin top position
  //    //}
  //    nodeList[i][j].vel = newVels[i][j]; //update vels
  //    nodeList[i][j].pos.add(nodeList[i][j].vel.times(dt)); //update pos
  //  // Fix the base node in place
  //  }
  //}

  // Update the velocities (PBD)
  //for(int i = 0; i < nodeList.length; i++){
  //  nodeList[i].vel = nodeList[i].pos.minus(nodeList[i].last_pos).times(1 / dt);
  //}
  
  //Trying to get collision with red ball
  
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
//String total_length_error(){ //calculate total length deviation, currently
//  total_dev = 0;
//  for(int j = 1; j < nodeList.length; j++){
//      Vec3 delta = nodeList[j].pos.minus(nodeList[j-1].pos);
//      float delta_len = delta.length();
//      float error = delta_len - link_length;
//      total_dev += error;
//  }
//  return("TotalDeviationLength:," + total_dev);
//}

//String total_energy(){ //calculate total energy in system, currently
//  float total_energy = 0;
//  float kinetic_energy = 0;
//  float potential_energy = 0;
//  for(int i = 0; i < nodeList.length; i++){
//    kinetic_energy += 0.5 * nodeList[i].vel.lengthSqr();
//    float node_height = (height - nodeList[i].pos.y * scene_scale) / scene_scale;
//    potential_energy += (9.8 * node_height);
//  }
//  total_energy = kinetic_energy + potential_energy;
//  return ("Total energy:,"+ total_energy);
//}

float time = 0;
void draw() {
  float dt = 1.0 / 20; //Dynamic dt: 1/frameRate; //0.05 dt do NOT change
  
  
    //TIMING FOR 30s output file -------------------------------------
    
    //end_sec = millis();
    //total_sec = abs(end_sec - start_sec);
    //if(total_sec >= 30000){
    //  paused = true;
    //  output.flush(); 
    //  output.close();
    //  exit();
    //}
    
    //--------------------------------------------------
    //PRINT DATA OUT FOR GRAPHING ONLY
    
    //output.println("Time:," +total_sec/1000+ "," + total_energy());
    //output.println("Time:," +total_sec/1000 + "," + total_length_error());
    
    //--------------------------------------------------
    if (!paused) {
      for (int i = 0; i < sub_steps; i++) {
        time += dt / sub_steps;
        update_physics(dt / sub_steps);
        camera.Update(dt/sub_steps);
      }
    }
    //cam debugging
    //println(camera.position);
    //println(camera.theta);
    //println(camera.phi);
    
    background(255);
    lights();
    
    //draw red obstacle ball
    
    noStroke();
    fill(255,0,0);
    pushMatrix();
    translate(ballPos.x, ballPos.y, ballPos.z);
    sphere(0.4*scene_scale);
    popMatrix();
    
    //beginShape(); //TEST TEXTURE
    //texture(flag);
    //vertex(nodeList[0][0].pos.x * scene_scale,nodeList[0][0].pos.y * scene_scale,nodeList[0][0].pos.z * scene_scale,0,0);
    //vertex(nodeList[49][0].pos.x * scene_scale,nodeList[49][0].pos.y * scene_scale,nodeList[49][0].pos.z * scene_scale,1,0);
    //vertex(nodeList[49][49].pos.x * scene_scale,nodeList[49][49].pos.y * scene_scale,nodeList[49][49].pos.z * scene_scale,1,1);
    //vertex(nodeList[0][49].pos.x * scene_scale,nodeList[0][49].pos.y * scene_scale,nodeList[0][49].pos.z * scene_scale,0,1);
    //endShape();
    
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

//Vec3 interpolate(Vec3 a, Vec3 b, float t){
//  return a.plus((b.minus(a)).times(t));
//}

//float interpolate(float a, float b, float t){
//  return a + ((b-a)*t);
//}

float dot(Vec3 a, Vec3 b){
  return a.x*b.x + a.y*b.y + a.z*b.z;
}
Vec3 vecCross(Vec3 a, Vec3 b){ 
return new Vec3(a.y*b.z - a.z*b.y, -(a.x*b.z - a.z*b.x), a.x*b.y - a.y*b.x);
}
//Vec3 projAB(Vec3 a, Vec3 b){
//  return b.times(a.x*b.x + a.y*b.y);
//}

//Vec3 perpendicular(Vec3 a) {
//  return new Vec3(-a.y, a.x);
//}
