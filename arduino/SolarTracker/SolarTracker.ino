/**
Solar Autotracker

This code is for an arduino to drive an LX50 mount to auto-track on the sun for solar observation.

NEVER LOOK DIRECTLY AT THE SUN.
NEVER POINT A TELESCOPE AT THE SUN WITHOUT AN APPROPRIATE SOLAR FILTER.

I totally disavow any responsibility for injury or damage due to using this code.


Author: Bryan Lunt <bjlunt2@illinois.edu>



*/
float NS_running=0.0;
float EW_running=0.0;
const float discount=0.1;

float NS_offset=0.0;
float EW_offset=0.0;

const float DIRECTION_MULT=-1.0;

const float MOVE_THRESHOLD = 0.001;
const float NEG_MOVE_THRESHOLD = -1.0*MOVE_THRESHOLD;

const int cloud_thresh = 2100;

const int CENTER_BUTTON = A0;
const int center_button_threshold = 500;

//WEST, EAST, NORTH, SOUTH are the pins (Currently)
//int WEST_PIN, EAST_PIN, NORTH_PIN, SOUTH_PIN;



//Which analog pins are being used to read the sensor?
const int NE_IN = A1;
const int NW_IN = A2;
const int SW_IN = A3;
const int SE_IN = A4;


/*
*These are the values for the hand-soldered prototype. (Rev B)
*

//Which digital pins are being used for output to steer the mount?
int WEST_PIN = 5;
int EAST_PIN = 4;
int NORTH_PIN = 6;
int SOUTH_PIN = 3;
*/

//Which digital pins are being used for output to steer the mount?
int WEST_PIN = 6;
int EAST_PIN = 3;
int NORTH_PIN = 4;
int SOUTH_PIN = 5;


void setup(){
  Serial.begin(9600);
  
  //Set pullup for A0, the centering button
  digitalWrite(CENTER_BUTTON, HIGH);
  
  pinMode(WEST_PIN,OUTPUT);
  pinMode(EAST_PIN,OUTPUT);
  pinMode(NORTH_PIN,OUTPUT);
  pinMode(SOUTH_PIN,OUTPUT);
  
  stop();
}

void move(){
  
  stop();
  
  float NS_compare = NS_running - NS_offset;
  float EW_compare = EW_running - EW_offset;
  
  if(NS_compare < NEG_MOVE_THRESHOLD){
     //move
     digitalWrite(SOUTH_PIN,HIGH);
  }else if(NS_compare > MOVE_THRESHOLD){
    //move
    digitalWrite(NORTH_PIN,HIGH);
  }
  
  if(EW_compare < NEG_MOVE_THRESHOLD){
    //move
    digitalWrite(EAST_PIN,HIGH);
  }else if(EW_compare > MOVE_THRESHOLD){
    //move
    digitalWrite(WEST_PIN,HIGH);
  }
  
}

void stop(){
   digitalWrite(WEST_PIN,LOW);
   digitalWrite(EAST_PIN,LOW);
   digitalWrite(NORTH_PIN,LOW);
   digitalWrite(SOUTH_PIN,LOW);
}

int read_sensor(){
  int ne_val,nw_val,sw_val,se_val;
  
  ne_val = analogRead(NE_IN);
  
  sw_val = analogRead(SW_IN);
  nw_val = analogRead(NW_IN);//reordered on purpose
  se_val = analogRead(SE_IN);
  
  int North = ne_val+nw_val;
  int South = sw_val+se_val;
  
  int East = ne_val + se_val;
  int West = nw_val + sw_val;
  
  int total = ne_val + nw_val + sw_val + se_val;
  if(total <= 0){
    total=1;
  }
  
  int NS = DIRECTION_MULT*(North-South); //negative means GO SOUTH
  int EW = DIRECTION_MULT*(West-East); //negative means GO WEST
  
  NS_running = (1.0-discount)*NS_running + discount*NS/total;
  EW_running = (1.0-discount)*EW_running + discount*EW/total;
  
  return total;
}


int check_set_centering(){
  if(analogRead(CENTER_BUTTON) <= center_button_threshold){
    NS_offset = NS_running;
    EW_offset = EW_running;
    return 1;
  }
  return 0;
}

void write_serial_output(int total){
  Serial.print(NS_running);
  Serial.print("\t");
  Serial.print(EW_running);
  Serial.print("\t");
  Serial.println(total);
  Serial.flush();
}

void loop(){

  int total = read_sensor();
  
  int centering_down = check_set_centering();

  write_serial_output(total);
  
  if(total > cloud_thresh && centering_down == 0){
    move();
  }else{
    stop();
  }
  
  delay(100);
}

