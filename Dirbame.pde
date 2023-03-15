int speed = 115200;
import meter.*;
Meter skalė;

import processing.serial.*;
Serial serija;
import controlP5.*;
ControlP5 cp5;
String vardas;
int potReiksme;
int rutuliukas = 0;
Chart šviesa;
int x = 300, y = 200;

void setup() {
  size(600, 400);

  cp5 = new ControlP5(this);
  cp5.setFont(createFont("Gabriola ", 16));

  //cp5.addButton("atnaujinti");
  cp5.addButton("atverti").setPosition(90, 10).setSize(80, 30);
  cp5.addButton("užverti").setPosition(170, 10).setSize(80, 30).linebreak();
  cp5.addToggle("led_13")
    .setMode(ControlP5.SWITCH)
    .setPosition(100, 50)
    .setSize(50, 20)
    ;
  cp5.addToggle("fenas")
    .setMode(ControlP5.SWITCH)
    .setPosition(170, 50)
    .setSize(50, 20)
    ;
  cp5.addToggle("rėlė")
    .setMode(ControlP5.SWITCH)
    .setPosition(240, 50)
    .setSize(50, 20)
    .linebreak()
    ;
  cp5.addScrollableList("portai")
    .setPosition(10, 10)
    .setSize(80, 100)
    .setBarHeight(30)
    .setItemHeight(30)
    .close()
    .addItems(Serial.list());

  cp5.addColorWheel("spalvos", 10, 200, 170 ).setRGB(color(128, 0, 255));
  noStroke();



  cp5.addKnob("servo")
    .setRange(0, 180)
    //.setValue(220)
    .setPosition(230, 100)
    .setRadius(30)
    .setNumberOfTickMarks(10)
    //.setTickMarkLength(4)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255, 255, 0))
    .setDragDirection(Knob.HORIZONTAL)
    ;

  šviesa = cp5.addChart("šviesa")
    .setPosition(330, 220)
    .setSize(250, 150)
    .setRange(0, 1023)
    .setView(Chart.LINE) 
    .setStrokeWeight(1.5)
    .setColorCaptionLabel(color(255))
    .addDataSet("incoming")
    .setData("incoming", new float[100])
    ;

  cp5.addSlider("šiluma")
    .setPosition(240, 190)
    .setSize(25, 180)
    .setRange(0, 55)
    .setNumberOfTickMarks(55)
    ;
    
  cp5.addTextfield("t").setPosition(10, 100).setSize(145, 30);
  cp5.addTextfield("tekstas").setPosition(10, 140).setSize(145, 30);
  cp5.addBang("ccc").setPosition(155, 100).setSize(45, 30);
  cp5.addBang("siūsti").setPosition(155, 140).setSize(45, 30);

  skalė = new Meter(this, 310, 10);
  skalė.setDisplayDigitalMeterValue(true);
  skalė.setMeterWidth(280);
  skalė.setUp(0, 1023, 0, 100, -180, 0);
  String[] scaleLabels = {"0", "20", "40", "60", "80", "100"};
  skalė.setScaleLabels(scaleLabels);
  skalė.setTitle("Potenciometro Reikšmė");
  skalė.setLowSensorWarningActive(true);
  skalė.setLowSensorWarningValue((float)10);
  skalė.setHighSensorWarningActive(true);
  skalė.setHighSensorWarningValue((float)80.0);


  String list[] = Serial.list();
  cp5.get(ScrollableList.class, "portai").addItems(list);
}


void portai(int n) {
  vardas = Serial.list()[n];
}
void atverti() {
  serija = new Serial(this, vardas, speed);
}
void užverti() {
  serija.stop();
}
void led_13(int val) {
  serija.write("0,"+ val +";");
}
void fenas(int val) {
  serija.write("3,"+ val + ";");
}
void rėlė(int val) {
  serija.write("4,"+ val + ";");
}
void ccc() {
  serija.write("5,"+ cp5.get(Textfield.class, "t").getText() +";");
 
}
void siūsti()  {
 serija.write("6,"+ cp5.get(Textfield.class, "tekstas").getText() +";");
}


void spalvos(int col) {
  String str = "1,";
  str += int(red(col));
  str +=',';
  str += int(green(col));
  str +=',';
  str += int(blue(col));
  str +=';';
  if (serija != null) serija.write(str);
}
void servo(int val) {
  String str = "2," + val +';';
  if (serija != null) serija.write(str);
}


void draw() {
  background(90);
  skalė.updateMeter(potReiksme);
  fill(rutuliukas);
  circle(x, y, 30);

  if (serija != null) {
    if (serija.available() > 0) {
      String str = serija.readStringUntil('\n');
      str = str.trim();
      String data[] = str.split(",");

      switch (int(data[0])) {
      case 0:
        potReiksme = int(data[1]);
        šviesa.push("incoming", int(data[2]));
        cp5.get(Slider.class, "šiluma").setValue(float(data[3]));
        //println(float(data[3]));
        break;
      case 1:
        rutuliukas = int(data[1]) * 255;
        break;
      case 2:
        x += map(int(data[1]), 0, 1023, -5, 5);
        y += map(int(data[2]), 0, 1023, -5, 5);
        break;
      }
    }
  }
}
