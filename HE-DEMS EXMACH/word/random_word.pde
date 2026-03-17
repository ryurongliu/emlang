import oscP5.*;
import netP5.*;
import java.util.ArrayList; 
import processing.serial.*;

OscP5 oscP5; 
NetAddress maxBroadcastLocation; 

//serial stuff
Serial myPort;
int portIndex = 3;


JSONObject word_json; 
JSONArray WORD_data; 

float hex_rad = 10;
float word_point_size = 10;
float bg_hex_rad = hex_rad * 2.3;

PImage word_image;


int morpheme_length = 3; //for MBR 
int sound_length = 1; // for SBR 
int curr_m_length = 0; //for SBR, total length of current morpheme 
int curr_m_sound = 1; //for SBR, which s of current m is currently being played 
int curr_m = 1; //which m currently being played 
boolean playing = false;
int morph_counter = 0;

int curr_sound = 1; // to send to max

boolean br = false; //true = sbr (sound-beat rhythm), false = mbr (morpheme-beat rhythm) 


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

//draw background 12 hexagons and outside line 
public void draw_bg(){
   
  
  //outside lines 
  push();
  translate(width/2, height/2);
  fill(100);
  stroke(100);
  strokeWeight(1);
  polygon(0, 0, bg_hex_rad*2 + 1, 6);
  
  rotate(PI/6.0);
  polygon(0, 0, bg_hex_rad*2 + 1, 6);
  pop(); 
  

  //filling in space between outside lines 
  for (int i = 0; i < 12; i ++){
    push();
    translate(width/2, height/2);
    rotate(i*PI/6.0);
    noStroke();
    fill(0);
    polygon_bottom_point(0, 0, bg_hex_rad, 6);
    pop(); 
  }
  
  //drawing large hexagons
  for (int i = 0; i < 12; i ++){
    push();
    translate(width/2, height/2);
    rotate(i*PI/6.0);
    
    if (playing == true && i%2 == 0 && i/2 == curr_m){
      color c = color(unhex(word_colors[curr_m]), 100);
      fill(unhex(word_colors[curr_m]));
    }
    else{
      noFill();
    }
    stroke(255);
    strokeWeight(0.15);
    polygon_bottom_point(0, 0, bg_hex_rad, 6);
    pop(); 
  }
  
}

String[] word_colors = new String[6]; 
int[] word_numsounds = new int[6]; 
int[] word_hap1s = new int[6];
int[] word_hap2s = new int[6];

void setup(){
  fullScreen();
  //size(770, 450);
  smooth();
  
  //setup broadcast to max stuff
  oscP5 = new OscP5(this, 8000);
  maxBroadcastLocation = new NetAddress("127.0.0.1", 6000);
  
  String portName = Serial.list()[portIndex];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(10);
  
  word_json = loadJSONObject("random_word_processing.json"); 
  WORD_data = word_json.getJSONArray("data");
  
  for (int i = 0; i < 6; i++){
    JSONObject m_data = WORD_data.getJSONObject(i);
    String hex = m_data.getString("color");
    int hap1 = m_data.getInt("hap1");
    int hap2 = m_data.getInt("hap2");
    int numsound = m_data.getInt("numsounds");
    
    word_colors[i] = hex;
    word_hap1s[i] = hap1;
    word_hap2s[i] = hap2;
    word_numsounds[i] = numsound; 
  }
  
  //load word image
  word_image = loadImage("word_image.png");
  
  //print(width, height);
  hex_rad = height/11;
  bg_hex_rad = hex_rad * 2.3;
  word_point_size = hex_rad / 8; 
  
}

 

void draw(){
  background(0);
  rectMode(CENTER);
  draw_bg();
  
  //if(br){
  //  push();
  //    text("MBR", width/12, width/12);
  //    text("(Morpheme-Beat Rhythm)", width/12, width/12 + 15);
  //  pop();
  //}
  //else{
  //  push();
  //    text("SBR", width/12, width/12); 
  //    text("(Sound-Beat Rhythm)", width/12, width/12 + 15);
  //  pop();
  //}
  
  if(playing){
    
    if(br){
      morpheme_beat(); 
    }
    
    else{
      sound_beat(); 
    }
    
  }
  
  image(word_image, width/2 - bg_hex_rad*2, height/2 - bg_hex_rad*2, bg_hex_rad*4, bg_hex_rad*4);
  
}

void morpheme_beat(){
  //morpheme-beat rhythm
  //all start @ 0
  if(morph_counter == 0){
    myPort.write(word_hap1s[curr_m]);
    OscMessage maxOscMessage = new OscMessage("/num");
    maxOscMessage.add(curr_sound);
    oscP5.send(maxOscMessage, maxBroadcastLocation);
    println(curr_sound); 
    curr_sound += 1; 
  }
  //sound 2/3 plays @ length/3
  else if (morph_counter == morpheme_length / 3 && word_numsounds[curr_m] == 3){
    OscMessage maxOscMessage = new OscMessage("/num");
    maxOscMessage.add(curr_sound);
    oscP5.send(maxOscMessage, maxBroadcastLocation);
    println(curr_sound); 
    curr_sound += 1; 
  }
  //hap2 and sound 2/2 play @ length/2 
  else if (morph_counter == morpheme_length / 2){
    println("trigger hap2", word_hap2s[curr_m]);
    myPort.write(word_hap2s[curr_m]);
    if(word_numsounds[curr_m] == 2){
      OscMessage maxOscMessage = new OscMessage("/num");
      maxOscMessage.add(curr_sound);
      oscP5.send(maxOscMessage, maxBroadcastLocation);
      println(curr_sound); 
      curr_sound += 1; 
    }
  }
  //sound 3/3 plays @ 2length/3 
  else if (morph_counter == 2 * morpheme_length / 3 && word_numsounds[curr_m] == 3){ 
    OscMessage maxOscMessage = new OscMessage("/num");
    maxOscMessage.add(curr_sound);
    oscP5.send(maxOscMessage, maxBroadcastLocation);
    println(curr_sound); 
    curr_sound += 1; 
  }
  
  //increment counter 
  if(morph_counter < morpheme_length){
    morph_counter += 1;
  }
  
  //reset 
  else{
    
    morph_counter = 0;
    curr_m += 1;
     
    if(curr_m >= 6){
      curr_m = 0;
      playing = false; 
      curr_sound = 1;
      myPort.write(9);
    }
  }
}


void sound_beat(){
  
  //sound-beat rhythm
  //all start @ 0
  if (morph_counter == 0){
    //do haptic
    myPort.write(word_hap1s[curr_m]);
    println("hap1", morph_counter);
    //send sound 
    OscMessage maxOscMessage = new OscMessage("/num");
    maxOscMessage.add(curr_sound);
    oscP5.send(maxOscMessage, maxBroadcastLocation);
    println("sound", curr_sound, morph_counter); 
    curr_sound += 1;
  }
  
  //for one sound:
  if (word_numsounds[curr_m] == 1){
    //play hap2 in the middle of sound 
    if (morph_counter == sound_length / 2){
      myPort.write(word_hap2s[curr_m]);
      println("hap2", morph_counter);
    }
  }
  
  //for two sounds:
  if (word_numsounds[curr_m] == 2){
    //play hap2 and sound2 after one sound length
    if (morph_counter == sound_length){
      myPort.write(word_hap2s[curr_m]);
      println("hap2", morph_counter); 
      
      OscMessage maxOscMessage = new OscMessage("/num");
      maxOscMessage.add(curr_sound);
      oscP5.send(maxOscMessage, maxBroadcastLocation);
      println("sound", curr_sound, morph_counter);
      curr_sound += 1;
    }
  }
  
  //for three sounds: 
  if(word_numsounds[curr_m] == 3){
    //sound2 first
    if(morph_counter == sound_length){
      OscMessage maxOscMessage = new OscMessage("/num");
      maxOscMessage.add(curr_sound);
      oscP5.send(maxOscMessage, maxBroadcastLocation);
      println("sound", curr_sound, morph_counter);
      curr_sound += 1;
    }
    //then hap2
    else if (morph_counter == 3*sound_length / 2){
      myPort.write(word_hap2s[curr_m]);
      println("hap2", morph_counter); 
    }
    //then sound3
    else if (morph_counter == 2*sound_length){
      OscMessage maxOscMessage = new OscMessage("/num");
      maxOscMessage.add(curr_sound);
      oscP5.send(maxOscMessage, maxBroadcastLocation);
      println("sound", curr_sound, morph_counter);
      curr_sound += 1;
    } 
  }
  
  //increment 
  if (morph_counter < curr_m_length){
    morph_counter += 1; 
  }
  //or reset 
  else{
    morph_counter = 0; 
    curr_m += 1;
    curr_m_sound = 1; 
    if (curr_m >= 6){
      curr_m = 0;
      playing = false; 
      curr_sound = 1; 
      myPort.write(9);
      curr_m_length = 0; 
    }
    else{
      curr_m_length = word_numsounds[curr_m] * sound_length; 
      println(curr_m_length); 
    }
  }
  
}

void keyPressed() {
  
 if (key == ' '){
    playing = true; 
    curr_m = 0; 
    morph_counter = 0;
    curr_m_length = word_numsounds[curr_m] * sound_length; 
    curr_m_sound = 1; 
    println(curr_m_length);
  }
  
 if (key == 'r'){
   br = !br;
 }
  
}
