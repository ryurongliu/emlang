int hap2 = 8;
int hap3 = 9;
int hap4 = 10;
int hap5 = 11;
int hap6 = 12;
int hap7 = 13;

const byte haps[6] = {8, 9, 10, 11, 12, 13};

int curr_pin_1;
int curr_pin_2;

void setup() {

  Serial.begin(9600);
  for (int i=0; i<sizeof(haps); i++) {
    pinMode (haps[i], OUTPUT);
  }


}


void loop() {
  // put your main code here, to run repeatedly:

  // for (int i=0; i<sizeof(haps); i++) {
  //   digitalWrite(haps[i], HIGH);
  //   delay(1000);
  //   digitalWrite(haps[i], LOW);
  //   delay(1000);
  // }

  while (Serial.available() > 0)
  {
    int number = Serial.read();
    int first = number % 10; 
    int second = (number - first) / 10;

    if (first != 0 && first != 9){

      //turn off previous
      digitalWrite(curr_pin_1, LOW);
      digitalWrite(curr_pin_2, LOW);

      //set current
      curr_pin_1 = num_to_pin(first);
      curr_pin_2 = num_to_pin(second);

      //turn on current
      digitalWrite(curr_pin_1, HIGH);
      digitalWrite(curr_pin_2, HIGH);
      
    }

    else if (first == 9){
      digitalWrite(curr_pin_1, LOW);
      digitalWrite(curr_pin_2, LOW);

      curr_pin_1 = 0;
      curr_pin_2 = 0; 
    }
  }

}

int num_to_pin(int num){
  if (num == 2){
    return hap2;
  }
  else if (num == 3){
    return hap3;
  }

  else if (num == 4){
    return hap4;
  }

  else if (num == 5){
    return hap5;
  }

  else if (num == 6){
    return hap6;
  }

  else if (num == 7){
    return hap7;
  }

}
