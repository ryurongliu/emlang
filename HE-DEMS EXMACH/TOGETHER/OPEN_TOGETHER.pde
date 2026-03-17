import oscP5.*;
import netP5.*;
import java.util.ArrayList; 
import processing.serial.*;

OscP5 oscP5; 
NetAddress maxBroadcastLocationSentence;
NetAddress maxBroadcastLocation; 

//serial stuff
Serial myPort;
int portIndex = 3; //SPECIFIC

Serial buttonPort;
int buttonPortIndex= 4; //SPECIFIC

JSONObject sentence_json;
JSONArray sentence_data; 

JSONObject word_json; 
JSONArray WORD_data; 

float sentence_point_size; 
float img_rad; 
float grid_rad; 

float hex_rad = 10;
float word_point_size = 10;
float bg_hex_rad = hex_rad * 2.3;

PImage sentence_image; 
PImage word_image;

int curr_word = 1;
int curr_morph = 1; 

int word_length = 12; //SETS SPEED, SPECIFIC
int word_counter = 0; 

boolean sentence_picked = false;
boolean word_picked = false;

boolean playing = false; 
//boolean hold = false; 

int num_words = 21; 

float[][] mpos_x = new float[6][21]; 
float[][] mpos_y = new float[6][21]; 

String[][] colors = new String[6][21]; 
int[][] hap1s = new int[6][21]; 
int[][] hap2s = new int[6][21];
int[][] numsounds = new int[6][21]; 

String[] word_colors = new String[6]; 
int[] word_numsounds = new int[6]; 
int[] word_hap1s = new int[6];
int[] word_hap2s = new int[6];


int morpheme_length = 6; //SET FOR TIME, SPECIFIC
int sound_length = 1; // for SBR 
int curr_m_length = 0; //for SBR, total length of current morpheme 
int curr_m_sound = 1; //for SBR, which s of current m is currently being played 
int curr_m = 1; //which m currently being played 
int morph_counter = 0;

int curr_sound = 1; // to send to max

//boolean br = false; //true = sbr (sound-beat rhythm), false = mbr (morpheme-beat rhythm) 


//for delaying start of animation
int delay_size = 100; //set size to 0 for instantaneous, SPECIFIC
int delay_counter = 0; 



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
    
    if (delay_counter == delay_size && playing == true && i%2 == 0 && i/2 == curr_m){
      //color c = color(unhex(word_colors[curr_m]), 100);
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

void setup(){
  //fullScreen();
  size(770, 450);
  smooth(); 
  
  oscP5 = new OscP5(this, 8000);
  maxBroadcastLocationSentence = new NetAddress("127.0.0.1", 5000);
  maxBroadcastLocation = new NetAddress("127.0.0.1", 6000);
  
  String portName = Serial.list()[portIndex];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(10);
  
  String buttonPortName = Serial.list()[buttonPortIndex];
  buttonPort = new Serial(this, buttonPortName, 9600);
  buttonPort.bufferUntil(10);
  
  //load sentence json stuff...
  sentence_json = loadJSONObject("random_sentence_processing.json");
  sentence_data = sentence_json.getJSONArray("data");

  
  for (int i = 0; i < 21; i++){
    JSONArray word_data = sentence_data.getJSONArray(i);
    for (int j = 0; j < 6; j++){
      JSONObject m_data = word_data.getJSONObject(j);
      String hex = m_data.getString("color");
      int hap1 = m_data.getInt("hap1");
      int hap2 = m_data.getInt("hap2");
      int numsound = m_data.getInt("numsounds"); 
      
      colors[j][i] = hex;
      hap1s[j][i] = hap1;
      hap2s[j][i] = hap2;
      numsounds[j][i] = numsound; 
    }
   
  }
  
  //load word json stuff
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
  
  sentence_image = loadImage("random_sentence_nobg_nogrid.png");
  
  img_rad = height/11 * 2.3 * 2; 
  sentence_point_size = (height / 11) / 8; 
  grid_rad = img_rad / 13.8; 
  
  initialize_mpos();
  
  
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
  
  //if(hold){
  //  perf_word(); 
  //}
  
  if(playing){
    
    if(delay_counter == delay_size){
      if (sentence_picked){
        perf_word(); 
        
        if(word_counter < word_length){
          word_counter += 1; 
        }
        else{
          word_counter = 0; 
          curr_word += 1; 
          curr_morph = 1;
          
          if (curr_word > num_words){
            playing = false; 
            //hold = true; 
            myPort.write(9);
            //curr_word -= 1;
          }
        }
      }
      
      if (word_picked){
        morpheme_beat();
      }
    }
    else{
      delay_counter += 1;
      print("delaying");
    }
  }
  

  if (sentence_picked){
    image(sentence_image, width/2 - img_rad, height/2 - img_rad, 2*img_rad, 2*img_rad);
  }
  
  if (word_picked){
    draw_bg();
    image(word_image, width/2 - bg_hex_rad*2, height/2 - bg_hex_rad*2, bg_hex_rad*4, bg_hex_rad*4);
  }
  
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

void perf_word(){
  //text(curr_word, width/2, height/2);
  
  //emission part
  push();
    //for(int i = 0; i < curr_word - 1; i++){
    //  fill(100, 100, 100, 100);
    //  noStroke();
    //  polygon(mpos_x[0][i], mpos_y[0][i], grid_rad, 6);
    //  polygon(mpos_x[1][i], mpos_y[1][i], grid_rad, 6);
    //  polygon(mpos_x[2][i], mpos_y[2][i], grid_rad, 6);
    //  polygon(mpos_x[3][i], mpos_y[3][i], grid_rad, 6);
    //  polygon(mpos_x[4][i], mpos_y[4][i], grid_rad, 6);
    //  polygon(mpos_x[5][i], mpos_y[5][i], grid_rad, 6);
    //}
    
    if(curr_word <= 21){
      noStroke();
      //emissions part
      fill(unhex(colors[0][curr_word-1]));
      polygon(mpos_x[0][curr_word-1], mpos_y[0][curr_word-1], grid_rad, 6);
      fill(unhex(colors[1][curr_word-1]));
      polygon(mpos_x[1][curr_word-1], mpos_y[1][curr_word-1], grid_rad, 6);
      fill(unhex(colors[2][curr_word-1]));
      polygon(mpos_x[2][curr_word-1], mpos_y[2][curr_word-1], grid_rad, 6);
      fill(unhex(colors[3][curr_word-1]));
      polygon(mpos_x[3][curr_word-1], mpos_y[3][curr_word-1], grid_rad, 6);
      fill(unhex(colors[4][curr_word-1]));
      polygon(mpos_x[4][curr_word-1], mpos_y[4][curr_word-1], grid_rad, 6);
      fill(unhex(colors[5][curr_word-1]));
      polygon(mpos_x[5][curr_word-1], mpos_y[5][curr_word-1], grid_rad, 6);
      
      if (word_counter >= 0 && word_counter < word_length / 12){
        fill(unhex(colors[0][curr_word-1]));
        polygon(mpos_x[0][curr_word-1], mpos_y[0][curr_word-1], grid_rad, 6);
      }
      else if (word_counter >= word_length / 6 && word_counter < word_length / 12 * 3){
        fill(unhex(colors[1][curr_word-1]));
        polygon(mpos_x[1][curr_word-1], mpos_y[1][curr_word-1], grid_rad, 6);
      }
      else if (word_counter >= 2 * word_length / 6 && word_counter < word_length / 12 * 5){
        fill(unhex(colors[2][curr_word-1]));
        polygon(mpos_x[2][curr_word-1], mpos_y[2][curr_word-1], grid_rad, 6);
      }
      else if (word_counter >= 3 * word_length / 6 && word_counter < word_length / 12 * 7){
        fill(unhex(colors[3][curr_word-1]));
        polygon(mpos_x[3][curr_word-1], mpos_y[3][curr_word-1], grid_rad, 6);
      }
      else if (word_counter >= 4 * word_length / 6 && word_counter < word_length / 12 * 9){
        fill(unhex(colors[4][curr_word-1]));
        polygon(mpos_x[4][curr_word-1], mpos_y[4][curr_word-1], grid_rad, 6);
      }
      else if (word_counter >= 5 * word_length / 6 && word_counter < word_length / 12 * 11){
        fill(unhex(colors[5][curr_word-1]));
        polygon(mpos_x[5][curr_word-1], mpos_y[5][curr_word-1], grid_rad, 6);
      }
      
      //haptics & sound part
      if (word_counter == 0){
        
        //morph1, hap1 and hap2
        int num = hap1s[0][curr_word-1] * 10 + hap2s[0][curr_word-1];
        myPort.write(num);
        println(num);
        //myPort.write(hap1s[0][curr_word-1]);
        //println(hap1s[0][curr_word-1]);
        //myPort.write(hap2s[0][curr_word-1]);
        //println(hap2s[0][curr_word-1]);
        
        //morph1, all sounds
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "1");
        maxOscMessage.add(1);
        oscP5.send(maxOscMessage, maxBroadcastLocationSentence);
      }
      else if(word_counter == word_length / 6){
        
        
        int num = hap1s[1][curr_word-1] * 10 + hap2s[1][curr_word-1];
        myPort.write(num);
        //myPort.write(hap1s[1][curr_word-1]);
        //println(hap1s[1][curr_word-1]);
        //myPort.write(hap2s[1][curr_word-1]);
        //println(hap2s[1][curr_word-1]);
        
        //morph2, all sounds
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "2");
        maxOscMessage.add(1);
        oscP5.send(maxOscMessage, maxBroadcastLocationSentence);
      }
      else if(word_counter == 2 * word_length / 6){
        
        int num = hap1s[2][curr_word-1] * 10 + hap2s[2][curr_word-1];
        myPort.write(num);
        println(num);
        //myPort.write(hap1s[2][curr_word-1]);
        //println(hap1s[2][curr_word-1]);
        //myPort.write(hap2s[2][curr_word-1]);
        //println(hap2s[2][curr_word-1]);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "3");
        maxOscMessage.add(1);
        oscP5.send(maxOscMessage, maxBroadcastLocationSentence);
      }
      else if(word_counter == 3 * word_length / 6){
        
        
        int num = hap1s[3][curr_word-1] * 10 + hap2s[3][curr_word-1];
        myPort.write(num);
        println(num);
        //myPort.write(hap1s[3][curr_word-1]);
        //println(hap1s[3][curr_word-1]);
        //myPort.write(hap2s[3][curr_word-1]);
        //println(hap2s[3][curr_word-1]);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "4");
        maxOscMessage.add(1);
        oscP5.send(maxOscMessage, maxBroadcastLocationSentence);
      }
      else if(word_counter == 4 * word_length / 6){
        
        
        int num = hap1s[4][curr_word-1] * 10 + hap2s[4][curr_word-1];
        myPort.write(num);
        println(num);
        //myPort.write(hap1s[4][curr_word-1]);
        //println(hap1s[4][curr_word-1]);
        //myPort.write(hap2s[4][curr_word-1]);
        //println(hap2s[4][curr_word-1]);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "5");
        maxOscMessage.add(1);
        oscP5.send(maxOscMessage, maxBroadcastLocationSentence);
      }
      else if(word_counter == 5 * word_length / 6){
        
        int num = hap1s[5][curr_word-1] * 10 + hap2s[5][curr_word-1];
        myPort.write(num);
        println(num);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "6");
        maxOscMessage.add(1);
        oscP5.send(maxOscMessage, maxBroadcastLocationSentence);
      }
    }
  pop(); 
  
}


void serialEvent(Serial buttonPort) {  // this gets called when something is received on the serial port
    char received = buttonPort.readString().charAt(0);  
    print(received);
    button(received);
    
}

void button(char b){
  
  print("inside button");
  println(b);
  
  if (b == 's'){
   //if(hold){
   //  hold = false; 
   //}
   //else{
   if (playing == false){ //only allow switching if not playing
    sentence_picked = true; 
    //hold = false; 
    word_picked = false;
    }
    
   //}

  }
  
  if (b == 'w'){
   //if(hold){
   //  hold = false; 
   //}
   //else{
   if (playing == false){ //only allow switching if not playing
    word_picked = true; 
    //hold = false; 
    sentence_picked = false;
    }
    
   //}

  }
  
 if (b == 'p'){
   //if(hold){
   //  hold = false; 
   //}
   //else{
    playing = true; 
    //hold = false; 
    delay_counter = 0;
    curr_word = 1; 
    curr_morph = 1; 
    word_counter = 0; 
   //}
  }
  
}

void keyPressed() {
  
  if (key == 's'){
   //if(hold){
   //  hold = false; 
   //}
   //else{
   if (playing == false){ //only allow switching if not playing
    sentence_picked = true; 
    //hold = false; 
    word_picked = false;
    }
    
   //}

  }
  
  if (key == 'w'){
   //if(hold){
   //  hold = false; 
   //}
   //else{
   if (playing == false){ //only allow switching if not playing
    word_picked = true; 
    //hold = false; 
    sentence_picked = false;
    }
    
   //}

  }
  
 if (key == ' '){
   //if(hold){
   //  hold = false; 
   //}
   //else{
    playing = true; 
    //hold = false; 
    delay_counter = 0;
    curr_word = 1; 
    curr_morph = 1; 
    word_counter = 0; 
   //}

  }
  
}

void initialize_mpos(){
  
  //do ring 6 first
  for(int i = 0; i < 6; i++){
    //m1 positions
    mpos_x[0][i] = width/2 + sqrt(3)*grid_rad*i;
    mpos_y[0][i] = height/2 - 12*grid_rad + grid_rad*i; 
    
    //m2 positions
    mpos_x[1][i] = width/2 + 6*sqrt(3)*grid_rad; 
    mpos_y[1][i] = height/2 - 6*grid_rad + 2*grid_rad*i;
    
    //m3 positiions
    mpos_x[2][i] = width/2 + 6*sqrt(3)*grid_rad - sqrt(3)*grid_rad*i;
    mpos_y[2][i] = height/2 + 6*grid_rad + grid_rad*i;
    
    //m4 positiosn
    mpos_x[3][i] = width/2 - sqrt(3)*grid_rad*i;
    mpos_y[3][i] = height/2 + 12*grid_rad - grid_rad*i; 
    
    //m5 positions
    mpos_x[4][i] = width/2 - 6*sqrt(3)* grid_rad;
    mpos_y[4][i] = height/2 + 6*grid_rad - 2*grid_rad*i;
    
    //m6 positions
    mpos_x[5][i] = width/2 - 6*sqrt(3)*grid_rad + sqrt(3)*grid_rad*i;
    mpos_y[5][i] = height/2 - 6*grid_rad - grid_rad*i;
  }
  
  //ring 5
  for(int i = 0; i < 5; i++){
    //m1 positions
    mpos_x[0][i+6] = width/2 + 5*sqrt(3)*grid_rad;
    mpos_y[0][i+6] = height/2 - 5*grid_rad + 2*grid_rad*i; 
    
    //m2 positions
    mpos_x[1][i+6] = width/2 + 5*sqrt(3)*grid_rad - sqrt(3)*grid_rad*i; 
    mpos_y[1][i+6] = height/2 + 5*grid_rad + grid_rad*i;
    
    //m3 positiions
    mpos_x[2][i+6] = width/2 - sqrt(3)*grid_rad*i;
    mpos_y[2][i+6] = height/2 + 10*grid_rad - grid_rad*i;
    
    //m4 positiosn
    mpos_x[3][i+6] = width/2 - 5*sqrt(3)*grid_rad;
    mpos_y[3][i+6] = height/2 + 5 *grid_rad - 2*grid_rad*i; 
    
    //m5 positions
    mpos_x[4][i+6] = width/2 - 5*sqrt(3)* grid_rad + sqrt(3)*grid_rad*i;
    mpos_y[4][i+6] = height/2 - 5*grid_rad - grid_rad*i;
    
    //m6 positions
    mpos_x[5][i+6] = width/2 + sqrt(3)*grid_rad*i;
    mpos_y[5][i+6] = height/2 - 10*grid_rad + grid_rad*i;
  }
  
  //ring 4
  for(int i = 0; i < 4; i++){
    //m1 positions
    mpos_x[0][i+10] = width/2 + 5*sqrt(3)*grid_rad - sqrt(3)*grid_rad*i;
    mpos_y[0][i+10] = height/2 + 3*grid_rad + grid_rad*i; 
    
    //m2 positions
    mpos_x[1][i+10] = width/2 + sqrt(3)*grid_rad - sqrt(3)*grid_rad*i; 
    mpos_y[1][i+10] = height/2 + 9*grid_rad - grid_rad*i;
    
    //m3 positiions
    mpos_x[2][i+10] = width/2 - 4*sqrt(3)*grid_rad;
    mpos_y[2][i+10] = height/2 + 6*grid_rad - 2*grid_rad*i;
    
    //m4 positiosn
    mpos_x[3][i+10] = width/2 - 5*sqrt(3)*grid_rad + sqrt(3)*grid_rad*i;
    mpos_y[3][i+10] = height/2 - 3 *grid_rad - grid_rad*i; 
    
    //m5 positions
    mpos_x[4][i+10] = width/2 - sqrt(3)* grid_rad + sqrt(3)*grid_rad*i;
    mpos_y[4][i+10] = height/2 - 9*grid_rad + grid_rad*i;
    
    //m6 positions
    mpos_x[5][i+10] = width/2 + 4*sqrt(3)*grid_rad;
    mpos_y[5][i+10] = height/2 - 6*grid_rad + 2*grid_rad*i;
  }
  
  //ring 4
  for(int i = 0; i < 3; i++){
    //m1 positions
    mpos_x[0][i+14] = width/2 + sqrt(3)*grid_rad - sqrt(3)*grid_rad*i;
    mpos_y[0][i+14] = height/2 + 7*grid_rad - grid_rad*i; 
    
    //m2 positions 
    mpos_x[1][i+14] = width/2 - 3*sqrt(3)*grid_rad; 
    mpos_y[1][i+14] = height/2 + 5*grid_rad - 2*grid_rad*i;
    
    //m3 positiions
    mpos_x[2][i+14] = width/2 - 4*sqrt(3)*grid_rad + sqrt(3)*grid_rad*i;
    mpos_y[2][i+14] = height/2 - 2*grid_rad - grid_rad*i;
    
    //m4 positiosn
    mpos_x[3][i+14] = width/2 - sqrt(3)*grid_rad + sqrt(3)*grid_rad*i;
    mpos_y[3][i+14] = height/2 - 7 *grid_rad + grid_rad*i; 
    
    //m5 positions
    mpos_x[4][i+14] = width/2 + 3*sqrt(3)* grid_rad;
    mpos_y[4][i+14] = height/2 - 5*grid_rad + 2*grid_rad*i;
    
    //m6 positions
    mpos_x[5][i+14] = width/2 + 4*sqrt(3)*grid_rad - sqrt(3)*grid_rad*i;
    mpos_y[5][i+14] = height/2 + 2*grid_rad + grid_rad*i;
  }
  
  //ring 3
  for(int i = 0; i < 3; i++){
    //m1 positions
    mpos_x[0][i+17] = width/2 - 2* sqrt(3)*grid_rad;
    mpos_y[0][i+17] = height/2 + 4*grid_rad - 2*grid_rad*i; 
    
    //m2 positions
    mpos_x[1][i+17] = width/2 - 3*sqrt(3)*grid_rad + sqrt(3)*grid_rad*i; 
    mpos_y[1][i+17] = height/2 - grid_rad - grid_rad*i;
    
    //m3 positiions
    mpos_x[2][i+17] = width/2 - sqrt(3)*grid_rad + sqrt(3)*grid_rad*i;
    mpos_y[2][i+17] = height/2 - 5*grid_rad + grid_rad*i;
    
    //m4 positiosn
    mpos_x[3][i+17] = width/2 + 2*sqrt(3)*grid_rad;
    mpos_y[3][i+17] = height/2 - 4*grid_rad + 2* grid_rad*i; 
    
    //m5 positions
    mpos_x[4][i+17] = width/2 + 3*sqrt(3)* grid_rad - sqrt(3)*grid_rad*i;
    mpos_y[4][i+17] = height/2 + grid_rad + grid_rad*i;
    
    //m6 positions
    mpos_x[5][i+17] = width/2 + sqrt(3)*grid_rad - sqrt(3)*grid_rad*i;
    mpos_y[5][i+17] = height/2 + 5*grid_rad - grid_rad*i;
  }
  
  
  mpos_x[0][20] = width/2 - sqrt(3)*grid_rad;
  mpos_y[0][20] = height/2 - grid_rad; 
  
  //m2 positions
  mpos_x[1][20] = width/2; 
  mpos_y[1][20] = height/2 - 2*grid_rad;
  
  //m3 positiions
  mpos_x[2][20] = width/2 + sqrt(3)*grid_rad;
  mpos_y[2][20] = height/2 - grid_rad;
  
  //m4 positiosn
  mpos_x[3][20] = width/2 + sqrt(3)*grid_rad;
  mpos_y[3][20] = height/2 + grid_rad; 
  
  //m5 positions
  mpos_x[4][20] = width/2;
  mpos_y[4][20] = height/2 + 2*grid_rad;
  
  //m6 positions
  mpos_x[5][20] = width/2 - sqrt(3)*grid_rad;
  mpos_y[5][20] = height/2 + grid_rad;
  
}
