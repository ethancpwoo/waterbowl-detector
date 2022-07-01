int waterPin = 9; 
int waterState = 0; 
void setup() {

  pinMode(waterPin, INPUT); 
  waterState = digitalRead(waterPin); 
  Serial.begin(9600); 
}

void loop() {

  Serial.write(waterState); 
  waterState = digitalRead(waterPin);
  Serial.flush(); 
  delay(100); 
}
