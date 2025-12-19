import oscP5.*;
import netP5.*;
import java.util.ArrayList; 
import processing.serial.*;

OscP5 oscP5; 
NetAddress maxBroadcastLocation; 

//serial stuff
Serial myPort;
int portIndex = 3;

JSONObject sentence_json;
JSONArray data; 

float point_size; 
float img_rad; 
float grid_rad; 

//PImage sentence_image; 

int curr_word = 1;
int curr_morph = 1; 

int word_length = 12; 
int word_counter = 0; 

boolean playing = true; 
boolean hold = false; 

int num_words = 21; 

float[][] mpos_x = new float[6][21]; 
float[][] mpos_y = new float[6][21]; 

String[][] colors = new String[6][21]; 
int[][] hap1s = new int[6][21]; 
int[][] hap2s = new int[6][21];
int[][] numsounds = new int[6][21]; 

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

void setup(){
  fullScreen();
  //size(770, 450);
  smooth(); 
  
  frameRate(12);
  
  oscP5 = new OscP5(this, 8000);
  maxBroadcastLocation = new NetAddress("127.0.0.1", 5000);
  
  String portName = Serial.list()[portIndex];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(10);
  
  //load sentence json stuff...
  sentence_json = loadJSONObject("sentence 2/random_sentence_2_processing.json");
  data = sentence_json.getJSONArray("data");
  
  for (int i = 0; i < 21; i++){
    JSONArray word_data = data.getJSONArray(i);
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
  
  //sentence_image = loadImage("random_sentence_nobg_nogrid.png");
  
  img_rad = height/11 * 2.3 * 2; 
  point_size = (height / 11) / 8; 
  grid_rad = img_rad / 13.8; 
  
  initialize_mpos();
  
  //start max recording
  OscMessage maxOscMessage = new OscMessage("/start");
  maxOscMessage.add("bang");
  oscP5.send(maxOscMessage, maxBroadcastLocation);
  
}

int end_counter = 0;

void draw(){
  background(0);
  rectMode(CENTER);
  
  if(hold){
    perf_word(); 
  }
  
  if(playing == false){
    //end max recording
    OscMessage maxOscMessage = new OscMessage("/stop");
    maxOscMessage.add("bang");
    oscP5.send(maxOscMessage, maxBroadcastLocation);
    exit();
  }
  
  if(playing){
    
    
    perf_word(); 
    
    if(word_counter < word_length){
      word_counter += 1; 
    }
    else{
      
      word_counter = 0; 
      curr_word += 1; 
      curr_morph = 1;
      
      if (curr_word > num_words){
        end_counter += 1;
        if (end_counter > 6){
          playing = false; 
          //hold = true; 
          myPort.write(9);
        }
        
        //curr_word -= 1;
        
      }
    }
  }
  
  saveFrame("sentence 2/frames/sentence-2-####.png");
  
  //image(sentence_image, width/2 - img_rad, height/2 - img_rad, 2*img_rad, 2*img_rad);
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
        
        //morph1, all sounds
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "1");
        maxOscMessage.add("bang");
        oscP5.send(maxOscMessage, maxBroadcastLocation);
      }
      else if(word_counter == word_length / 6){
        
        
        int num = hap1s[1][curr_word-1] * 10 + hap2s[1][curr_word-1];
        myPort.write(num);
        
        //morph2, all sounds
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "2");
        maxOscMessage.add("bang");
        oscP5.send(maxOscMessage, maxBroadcastLocation);
      }
      else if(word_counter == 2 * word_length / 6){
        
        int num = hap1s[2][curr_word-1] * 10 + hap2s[2][curr_word-1];
        myPort.write(num);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "3");
        maxOscMessage.add("bang");
        oscP5.send(maxOscMessage, maxBroadcastLocation);
      }
      else if(word_counter == 3 * word_length / 6){
        
        
        int num = hap1s[3][curr_word-1] * 10 + hap2s[3][curr_word-1];
        myPort.write(num);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "4");
        maxOscMessage.add("bang");
        oscP5.send(maxOscMessage, maxBroadcastLocation);
      }
      else if(word_counter == 4 * word_length / 6){
        
        
        int num = hap1s[4][curr_word-1] * 10 + hap2s[4][curr_word-1];
        myPort.write(num);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "5");
        maxOscMessage.add("bang");
        oscP5.send(maxOscMessage, maxBroadcastLocation);
      }
      else if(word_counter == 5 * word_length / 6){
        
        int num = hap1s[5][curr_word-1] * 10 + hap2s[5][curr_word-1];
        myPort.write(num);
        
        OscMessage maxOscMessage = new OscMessage("/word" + str(curr_word));
        maxOscMessage.add("/morph" + "6");
        maxOscMessage.add("bang");
        oscP5.send(maxOscMessage, maxBroadcastLocation);
      }
    }
  pop(); 
  
}


void keyPressed() {
  
 if (key == ' '){
   //if(hold){
   //  hold = false; 
   //}
   //else{
    playing = true; 
    //hold = false; 
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
