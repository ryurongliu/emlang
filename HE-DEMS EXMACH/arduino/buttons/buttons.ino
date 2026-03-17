void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(10, INPUT_PULLUP);
  pinMode(9, INPUT_PULLUP);
  pinMode(8, INPUT_PULLUP);
}

int play_status = 1;
int play_prev = 1;
int sentence = 1;
int s_prev = 1;
int w_prev = 1;

void loop() {
  // put your main code here, to run repeatedly:
  play_status = digitalRead(8);
  sentence = digitalRead(9);
  int word = digitalRead(10);

  if (play_status==0 && play_prev == 1){
    Serial.println("p");
    play_prev = 0;
  }
  else if (play_status==1 && play_prev == 0){
    play_prev = 1;
  }
  if (sentence==0 && s_prev == 1){
    Serial.println("s");
    s_prev = 0;
  }
  else if (sentence == 1 && s_prev == 0){
    s_prev = 1;
  }

  if (word == 0 && w_prev == 1){
    Serial.println("w");
    w_prev = 0;
  }
  else if (word == 1 && w_prev == 0){
    w_prev = 1;
  }
}
