import oscP5.*;
import netP5.*;
import java.util.ArrayList; 

OscP5 oscP5; 
NetAddress maxBroadcastLocation; 


//from start e-level to end e-level 
//transition energy wavelength 
public class Transition
{
  int start;
  int end; 
  float wavelength; 
  
  public Transition(int start, int end, float wavelength){
    this.start = start;
    this.end = end; 
    this.wavelength = wavelength; 
  }
}


float hex_rad = 10;
float point_size = 10; 
//single EMShape 
public class EMShape
{
  int number; //indexed from 0, order in word
  
  Transition transition;
  float shifted_wlength; 
  int shifted_r;
  int shifted_g;
  int shifted_b;
  int unshifted_r;
  int unshifted_g;
  int unshifted_b; 
  int width_mod; //0-none, 1-sLeL, 2-sL, 3-eL, 4-sD, 5eD
  int shape_mod; //0-none, 1-t, 2-rt, 3-bp, 4-lp, 5-hp 
  
  ArrayList<Boolean> pmod; //true or false if present 
  ArrayList<Transition> p_transitions;
  
  public EMShape(int num, Transition transition, int width_mod, int shape_mod, ArrayList<Boolean> pmod, ArrayList<Transition> p_trans, int sr, int sg, int sb, int ur, int ug, int ub){
    this.number = num;
    this.transition = transition;
    this.width_mod = width_mod;
    this.shape_mod = shape_mod;
    this.pmod = pmod;
    this.p_transitions = p_trans; 
    this.shifted_r = sr;
    this.shifted_g = sg;
    this.shifted_b = sb;
    this.unshifted_r = ur;
    this.unshifted_g = ug;
    this.unshifted_b = ub;
    
    this.shifted_wlength = 380 + (transition.wavelength - 121.57) / (12370 - 121.57) * 400; 
  }
  
  public void draw(int center_x, int center_y, boolean draw_hex){
    //print("drawing shape", this.number); 
    
    push();
    translate(center_x, center_y); 
    rotate(this.number * PI / 3.0);
    strokeWeight(0.5);
    stroke(255, 0, 0);
    ArrayList<ArrayList<Float>> hexpoints = polygon_points(0, -hex_rad * 2, hex_rad, 6, draw_hex); 
    stroke(255);
    
      //draw solid points 
      push();
        //draw startpoint based on number
        strokeWeight(point_size);
        stroke(255);
        int start_ind = this.transition.start - 2; 
        ArrayList<Float> start_coords = hexpoints.get(start_ind); 
        point(start_coords.get(0), start_coords.get(1));
        //draw endpoint based on number
        ArrayList<Float> end_coords = new ArrayList<Float>();
        if(this.transition.end == 1){
          point(0, -hex_rad * 2);
          end_coords.add(0.0);
          end_coords.add(-hex_rad * 2);
        }
        else{
          int end_ind = this.transition.end - 2;
          end_coords = hexpoints.get(end_ind);
          point(end_coords.get(0), end_coords.get(1));
          //draw center circle
          strokeWeight(1);
          circle(0, -hex_rad*2, point_size);
          
        }
        
      pop(); 
      
      
      //draw line
      this.draw_line(start_coords, end_coords);
      
      //draw shapemod
      this.draw_shapemod(start_coords, end_coords); 
      
      //draw pmod lines 
      this.draw_pmod_lines(hexpoints); 
      
      this.draw_pmods(hexpoints.get(0));
    
    pop(); 
  }
  
  public void draw_line(ArrayList<Float> start, ArrayList<Float> end){
    //for now, just draw a line 
    push();
    strokeWeight(3);
    stroke(255);
    line(start.get(0), start.get(1), end.get(0), end.get(1));
    pop();
  }
  
  public void draw_shapemod(ArrayList<Float> start, ArrayList<Float> end){
    
  }
  
  public void draw_pmod_lines(ArrayList<ArrayList<Float>> hexpoints){
    push();
    strokeWeight(0.75);
    for (int i = 0; i < 3; i++){
      Transition t = this.p_transitions.get(i);
      if(t.start != -1){
        ArrayList<Float> start = hexpoints.get(t.start - 2);
        ArrayList<Float> end = new ArrayList<Float>();
        if(t.end == 1){
          end.add(0.0);
          end.add(-hex_rad*2); 
        }
        else{
          end = hexpoints.get(t.end - 2);
        }
        line(start.get(0), start.get(1), end.get(0), end.get(1));
      }
    }
    pop();
    
  }
  
  public void draw_pmods(ArrayList<Float> top){
    
  }
  
  public void pronounce(){
    print("pronouncing shape", this.number); 
  }
  
}

public class EMWord
{
  ArrayList<EMShape> shapes; 
  int x;
  int y;
  
  public EMWord(ArrayList<EMShape> shapes, int x, int y){
    this.shapes = shapes;
    this.x = x;
    this.y = y; 
  }
  
  public void draw(boolean draw_hex){
    this.draw_bg();
    for(int i = 0; i < this.shapes.size(); i++){
      EMShape shape = this.shapes.get(i); 
      shape.draw(this.x, this.y, draw_hex); 
    }
    
  }
  
  public void draw_bg(){
    float bg_hex_rad = hex_rad * 2.3; 
    

    
    push();
    translate(width/2, height/2);
    fill(100);
    stroke(100);
    strokeWeight(1);
    polygon(0, 0, bg_hex_rad*2 + 1, 6);
    
    rotate(PI/6.0);
    polygon(0, 0, bg_hex_rad*2 + 1, 6);
    pop(); 
    for (int i = 0; i < 12; i ++){
      push();
      translate(width/2, height/2);
      rotate(i*PI/6.0);
      noStroke();
      fill(0);
      polygon_bottom_point(0, 0, bg_hex_rad, 6);
      pop(); 
    }
    for (int i = 0; i < 12; i ++){
      push();
      translate(width/2, height/2);
      rotate(i*PI/6.0);
      noFill();
      stroke(255);
      strokeWeight(0.15);
      polygon_bottom_point(0, 0, bg_hex_rad, 6);
      pop(); 
    }
    
        push();
      translate(width/2, height/2);
      translate(0, -hex_rad + point_size);
      stroke(255);
      strokeWeight(1);
      noFill();
      circle(0, 0, point_size * 2);
    pop();
  }
  
  public void pronounce(){
    for(int i = 0; i < this.shapes.size(); i++){
      EMShape shape = this.shapes.get(i); 
      shape.pronounce(); 
    }
  }
}

EMWord EMspeaker; 

boolean hex_overlay = false; ;
boolean lambda_shift = false ; 
boolean localized = false ; 

boolean playing = false ; 
int curr_shape = 0; 
int curr_pmod = 0; 
int total_mods = 11; 
int pcounter = 0;

void setup(){
  fullScreen();
  //size(770, 450);
  smooth();
  
  //setup broadcast to max stuff
  oscP5 = new OscP5(this, 8000);
  maxBroadcastLocation = new NetAddress("127.0.0.1", 5000);
  
  
  //list of shapes 
  ArrayList<EMShape> shapes = new ArrayList<EMShape>(); 
  
  //s1 Ly-alpha
  Transition s1_trans = new Transition(2, 1, 121.57); //Ly-alpha
  int s1_wmod = 0; //no width change 
  int s1_smod = 0; //no shape change 
  ArrayList<Boolean> s1_pmod = new ArrayList<Boolean>();
  s1_pmod.add(true);
  s1_pmod.add(true);
  s1_pmod.add(true);
  ArrayList<Transition> s1_ptrans = new ArrayList<Transition>();
  s1_ptrans.add(new Transition(7, 5, 4654.)); 
  s1_ptrans.add(new Transition(7, 3, 1005.)); 
  s1_ptrans.add(new Transition(5, 3, 1282.)); 
  EMShape s1 = new EMShape(0, s1_trans, s1_wmod, s1_smod, s1_pmod, s1_ptrans, 97, 0, 0, -1, -1, -1);
  shapes.add(s1);
  
  
  //s2 Ba-alpha
  Transition s2_trans = new Transition(3, 2, 656.3); //Ba-alpha
  int s2_wmod = 0; //no width change 
  int s2_smod = 1; //triangle shape 
  ArrayList<Boolean> s2_pmod = new ArrayList<Boolean>(3);
  s2_pmod.add(false);
  s2_pmod.add(true);
  s2_pmod.add(false);
  ArrayList<Transition> s2_ptrans = new ArrayList<Transition>(3);
  s2_ptrans.add(new Transition(-1, -1, -1)); 
  s2_ptrans.add(new Transition(5, 2, 434)); 
  s2_ptrans.add(new Transition(-1, -1, -1)); 
  EMShape s2 = new EMShape(1, s2_trans, s2_wmod, s2_smod, s2_pmod, s2_ptrans, 130, 0, 171, 255, 0, 0);
  shapes.add(s2);
  
  
   //s3 Pa-alpha
  Transition s3_trans = new Transition(4, 3, 1875); //Pa-alpha
  int s3_wmod = 0; //no width change 
  int s3_smod = 2; //reverse tri
  ArrayList<Boolean> s3_pmod = new ArrayList<Boolean>(3);
  s3_pmod.add(true);
  s3_pmod.add(true);
  s3_pmod.add(false);
  ArrayList<Transition> s3_ptrans = new ArrayList<Transition>(3);
  s3_ptrans.add(new Transition(6, 3, 1094)); 
  s3_ptrans.add(new Transition(5, 3, 1282)); 
  s3_ptrans.add(new Transition(-1, -1, -1)); 
  EMShape s3 = new EMShape(2, s3_trans, s3_wmod, s3_smod, s3_pmod, s3_ptrans, 22, 0, 255, -1, -1, -1);
  shapes.add(s3);
  
  
   //s4 Br-alpha
  Transition s4_trans = new Transition(5, 4, 4522.5); //Br-alpha
  int s4_wmod = 0; //no width change 
  int s4_smod = 3; //bp
  ArrayList<Boolean> s4_pmod = new ArrayList<Boolean>(3);
  s4_pmod.add(false);
  s4_pmod.add(true);
  s4_pmod.add(true);
  ArrayList<Transition> s4_ptrans = new ArrayList<Transition>(3);
  s4_ptrans.add(new Transition(-1, -1, -1)); 
  s4_ptrans.add(new Transition(5, 2, 434)); 
  s4_ptrans.add(new Transition(6, 3, 1094)); 
  EMShape s4 = new EMShape(3, s4_trans, s4_wmod, s4_smod, s4_pmod, s4_ptrans, 69, 255, 0, -1, -1, -1);
  shapes.add(s4);
  
  
    //s5 Pf-alpha
  Transition s5_trans = new Transition(6, 5, 7460); //Pf-alpha
  int s5_wmod = 0; //no width change 
  int s5_smod = 4; //lp
  ArrayList<Boolean> s5_pmod = new ArrayList<Boolean>(3);
  s5_pmod.add(true);
  s5_pmod.add(false);
  s5_pmod.add(false);
  ArrayList<Transition> s5_ptrans = new ArrayList<Transition>(3);
  s5_ptrans.add(new Transition(7, 4, 2166)); 
  s5_ptrans.add(new Transition(-1, -1, -1)); 
  s5_ptrans.add(new Transition(-1, -1, -1)); 
  EMShape s5 = new EMShape(4, s5_trans, s5_wmod, s5_smod, s5_pmod, s5_ptrans, 255, 120, 0, -1, -1, -1);
  shapes.add(s5);
  
  
  
  //s6 Hu-alpha
  Transition s6_trans = new Transition(7, 6, 12370); //Hu-alpha
  int s6_wmod = 0; //no width change 
  int s6_smod = 5; //hp
  ArrayList<Boolean> s6_pmod = new ArrayList<Boolean>(3);
  s6_pmod.add(true);
  s6_pmod.add(false);
  s6_pmod.add(true);
  ArrayList<Transition> s6_ptrans = new ArrayList<Transition>(3);
  s6_ptrans.add(new Transition(6, 1, 93.78)); 
  s6_ptrans.add(new Transition(-1, -1, -1)); 
  s6_ptrans.add(new Transition(7, 5, 4654)); 
  EMShape s6 = new EMShape(5, s6_trans, s6_wmod, s6_smod, s6_pmod, s6_ptrans, 97, 0, 0, -1, -1, -1);
  shapes.add(s6);
  
  //create word from all shapes, place at center of screen 
  EMspeaker = new EMWord(shapes, width/2, height/2);
  
  
  //draw word 
  print(width, height);
  hex_rad = height/11;
  point_size = hex_rad / 8; 
  
  localized = false; 
  
  
}



int p_speed = 1;

boolean slowed = false; 

void draw(){
  background(0);
    noFill();
  stroke(255);
  EMspeaker.draw(hex_overlay);
  
  push();
    noStroke();
    fill(255);
    textSize(height/30);
    rectMode(CENTER); 
    
    if(lambda_shift){
      text("\u03bb SHIFTED TO VISUAL", width/30, height/2);
    }
    
    
    if(localized){
      text("EMISSIONS LOCALIZED", width/30, height/2 + height/30);
    }

    if (hex_overlay){
      text("HEXGRID OVERLAY", width/30, height/2 + 2*height/30);
    }
    
    if (slowed){
      text("SLOWED 10x", width/30, height/2 + 3*height/30);
    }
  pop();

  if(playing){
    //send pmod message to max if it's the first time 
    if (pcounter == 0){
      OscMessage myOscMessage = new OscMessage("/num");
      myOscMessage.add(curr_pmod+1);
      oscP5.send(myOscMessage, maxBroadcastLocation); 
    }
    //draw shape color (unlocalized)  
      if(curr_pmod < 3){
        curr_shape = 0;
      }
      else if (curr_pmod == 3){
        curr_shape = 1;
      }
      else if (curr_pmod == 4 || curr_pmod == 5){
        curr_shape = 2; 
      }
      else if (curr_pmod == 6 || curr_pmod == 7){
        curr_shape = 3;
      }
      else if (curr_pmod == 8){
        curr_shape = 4; 
      }
      else{
        curr_shape = 5; 
      }
      EMShape shape = EMspeaker.shapes.get(curr_shape); 
      push(); 
      noStroke();
      if(lambda_shift == false){
        if(shape.unshifted_r != -1){
          fill(shape.unshifted_r, shape.unshifted_g, shape.unshifted_b, 100);
        }
        else{
          noFill();
        }
      }
      else{
        fill(shape.shifted_r, shape.shifted_g, shape.shifted_b, 100);
      }
      
      rectMode(CENTER);
      if(!localized){
        rect(width/2, height/2, width, height); 
      }
      else{
        translate(width/2, height/2); 
        rotate(curr_shape * PI / 3.0);
        polygon_bottom_point(0, 0, hex_rad * 2.3, 6);
      }
      pop(); 
    
    //increment pcounter / curr p
    if(pcounter < p_speed){
      pcounter += 1;
    }
    else{
      pcounter = 0;
      curr_pmod += 1;
      if(curr_pmod == total_mods){
        playing = false; 
      }
      
    }
  }
 
}







//https://processing.org/examples/regularpolygon.html
ArrayList<ArrayList<Float>> polygon_points(float x, float y, float radius, int npoints, boolean draw) {
  float angle = TWO_PI / npoints;
  ArrayList<ArrayList<Float>> polypoints = new ArrayList<ArrayList<Float>>();
  
  if(draw){
    
    beginShape();
  }
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a + PI / 6.0 - 2*PI/3.0) * radius;
    float sy = y + sin(a + PI / 6.0 - 2*PI/3.0) * radius;
    
    if(draw){
      vertex(sx, sy);
    }
    
    
    
    ArrayList<Float> point = new ArrayList<Float>();
    point.add(sx);
    point.add(sy);
    polypoints.add(point);
  }
  if(draw){
    
    endShape(CLOSE);
  }
  return polypoints; 
}

void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
    beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a + PI / 6.0) * radius;
    float sy = y + sin(a + PI / 6.0) * radius;

      vertex(sx, sy);
  }
    endShape(CLOSE);

}

void polygon_bottom_point(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  y -= radius; 
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a - PI / 6.0) * radius;
    float sy = y + sin(a - PI / 6.0) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}



void keyPressed() {
  if (key == 'h'){
    hex_overlay = !hex_overlay;
  }
  
  else if (key == 'w'){
    lambda_shift = !lambda_shift;
    
  }
  
  else if (key == 'l'){
    localized = !localized; 
  }
  
  else if (key == ' '){
    playing = true; 
    curr_shape = 0; 
    curr_pmod = 0;
    pcounter = 0;
  }
  
  else if (key == 's'){
    slowed = !slowed;
    if (slowed){
      p_speed = 10;
    }
    else{
      p_speed = 1;
    }
  }
}
