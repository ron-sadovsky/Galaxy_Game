//////////////////////////////////////////////////////////////////////////
//                                                                      //
//   _____                _____           _                _            //
//  |  __ \              / ____|         | |              | |           //
//  | |__) |___  _ __   | (___   __ _  __| | _____   _____| | ___   _   //
//  |  _  // _ \| '_ \   \___ \ / _` |/ _` |/ _ \ \ / / __| |/ / | | |  //
//  | | \ \ (_) | | | |  ____) | (_| | (_| | (_) \ V /\__ \   <| |_| |  //
//  |_|  \_\___/|_| |_| |_____/ \__,_|\__,_|\___/ \_/ |___/_|\_\\__, |  //
//                                                              __/ |   //
//                                                             |___/    //
// Due Date: Tuesday, May 24, 2016 / Submitted May 31 (sorry)           //
// Description: Galaxy Game - Final Submission                          //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

int shipW = 30;          
int shipH = 50;  
int shipX = 400; // spaceship is in the middle of the screen
int shipY = 536;
int shipSpeed = 5;

PImage images[] = new PImage[3]; //ship sprite
int currentFrame = 1; //current frame for ship sprite
int currentFrame2 = 0; //current frame for ship explosion sprite

PImage exp[] = new PImage[12]; //explosion sprite for asteroids
PImage exp2[] = new PImage[12]; //explosion sprite for ship - when reaching zero lives
int currentExpF[] = new int[100]; //current explosion sprite frame
boolean [] isExploding = new boolean[100]; //determines whether there is an explosion occurring on each asteroid

Minim minim;

AudioPlayer bgnmusic;
AudioPlayer lasersound;

PImage asteroid;
PImage background;
PImage bullet;
PImage ssbgn; //background for start screen and end screen

PFont font;
PFont font2;

int dist;
int ballD = 50;

int bgnX; //x value of background image
int bgnY; //y value of background image

int bulletSpeed = 10;
int currentBullet = 0; // index of the current bullet, loaded in the gun
int [] bulletX = new int [100];
int [] bulletY = new int [100];

int [] ballX = new int [100];
int [] ballY = new int [100];

int redness = 0; //used to make the ship turn red when hitting an asteroid

int currentBall = 0;

boolean [] bulletVisible = new boolean [100];
boolean [] ballVisible = new boolean [100];

boolean[] keys;          

boolean triggerReleased = true;

boolean buttonPressed = false; //used to operate the button on start screen
boolean shipVisible = true; //used to make ship invisible when reaching zero lives

float ballSpeed = 5;

int score = 0;
int lives = 3;

int timer; //used to add a delay after reaching zero lives before displaying the end screen

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

void generateBullets() {
  for (int i = 0; i<bulletX.length; i++) {
    bulletX[i] = -50;
    bulletY[i] = -50;
    bulletVisible[i] = false;
  }
}

void generateBall() {
  for (int i = 0; i<100; i++) {
    ballX[i] = int(random(width));
    ballY[i] = int(random(-8*height, 0));
    ballVisible[i] = true;
  }
}

int distance (int x1, int y1, int x2, int y2) {
  return round(sqrt(pow((x1 - x2), 2) + pow((y1 - y2), 2)));
}

void checkCollision() {
  for (int i = 0; i<100; i++) {
    for (int j = 0; j<100; j++) {
      dist = distance(ballX[i], ballY[i], bulletX[j], bulletY[j]);

      if (ballVisible[i] && bulletVisible[j] && dist < ballD/2) {
        ballVisible[i] = false;
        bulletVisible[j] = false;
        isExploding[i] = true;
        score++;
      }

      if (isExploding[i]==false) {
        currentExpF[i] = 0;
      }
    }
  }
}


void checkShip() { //checks ship collisions
  for (int i = 0; i<100; i++) {
    dist = distance(ballX[i], ballY[i], shipX, shipY);
    if (ballVisible[i] == true && dist < ballD/2+46) {
      ballVisible[i] = false;
      lives--;
      redness = 255;
    }
  }
}

void expImage() { //used to animate explosions when asteroids are shot
  for (int i = 0; i<exp.length; i++) {
    String expName = "eframe" + i + ".gif";
    exp[i] = loadImage(expName);
    exp[i].resize(100, 100);
  }
}

void expImageZ() { //used to upload explosion images for the ship
  for (int i = 0; i<exp2.length; i++) {
    String expName = "eframe" + i + ".gif";
    exp2[i] = loadImage(expName);
    exp2[i].resize(200, 200);
  }
}

void expImageZ2() { //used to animate explosions for the ship upon reaching zero lives
  if (currentFrame2 < exp2.length) {
    image(exp2[currentFrame2], shipX-100, shipY-100);

    if (frameCount%4==0) {
      currentFrame2++;
    }
  }
}

void shipImage1() { //uploads ship image for the setup
  for (int i = 0; i<images.length; i++) {
    String imageName = "frame" + i + ".gif";
    images[i] = loadImage(imageName);
  }
}

void shipImage2() { //sets up the ship image for the draw
  if (frameCount%4==0) {
    currentFrame++;
  }

  if (currentFrame >= images.length) {
    currentFrame = 1;
  }
}

void imageLoad() {
  background = loadImage("starbgn.png");
  background.resize(800,600);
  asteroid = loadImage("asteroid.png");
  asteroid.resize(100, 100);
  bullet = loadImage("spacebullet.png");
  ssbgn = loadImage("galaxybgn.jpg");
  ssbgn.resize(800,600);
  font = loadFont("EngraversMT-Bold-48.vlw");
  font2 = loadFont("AmericanTypewriter-Bold-48.vlw");
}

void startScreen() {
  textFont(font);
  textAlign(CENTER);
  background(ssbgn);
  fill(255);
  textSize(65);
  text("GALAXY", 400, 125);

  textFont(font2);
  textSize(22);

  fill(255);
  text("Use arrow keys to move", 400, 350);
  text("Press spacebar to shoot", 400, 380);
  text("Press START to begin playing", 400, 410);

  if (mouseX > 325 && mouseX < 475 && mouseY > 500 && mouseY < 550) {
    fill(175);
    rect(325, 500, 150, 50);
  } else {
    fill(255);
    rect(325, 500, 150, 50);
  }

  textSize(30);
  fill(0);
  text("START", 400, 535);
}

void endScreen() {
  background(ssbgn);
  textSize(65);
  text("Game over", 400, 200);
  textSize(30);
  text("Your score was "+score, 400, 450);
}

void redrawGameField() {
  for (int i = 0; i<bulletVisible.length; i++) {
    if (bulletVisible[i] == true) {
      fill(255, 0, 0);
      image(bullet, bulletX[i]-14, bulletY[i]-76);
    }
  }
  for (int i = 0; i<ballVisible.length; i++) {
    if (ballVisible[i] == true) {
      fill(255);
      ellipse(ballX[i], ballY[i], 50, 50);
      image(asteroid, ballX[i]-50, ballY[i]-50);
    }

    if (ballY[i] > height+50) {
      ballVisible[i] = true;
      ballX[i] = int(random(width));
      ballY[i] = int(random(-8*height, 0));
    }

    if (bulletY[i] < 0) {
      bulletVisible[i] = false;
    }

    if (isExploding[i]) {
      image(exp[currentExpF[i]], ballX[i]-50, ballY[i]-50);

      if (frameCount%2==0) {
        currentExpF[i]++;
      }

      if (currentExpF[i] >= exp.length) {
        isExploding[i] = false;
        currentExpF[i] = 0;
        ballVisible[i] = true;
        ballX[i] = int(random(width));
        ballY[i] = int(random(-8*height, 0));
      }
    }
  }
  if (shipVisible) {
    if (redness>0) {
      redness-=5;
    }
    tint(255, 255-redness, 255-redness);
    image(images[currentFrame], shipX-64, shipY-64);
    noTint();
  }
}

void moveBullets() {
  for (int i = 0; i<bulletVisible.length; i++) {
    if (bulletVisible[i] == true) {
      bulletY[i] -= bulletSpeed;
    }
  }
}

void moveBall() {
  for (int i = 0; i<ballVisible.length; i++) {
    if (ballVisible[i] == true) {
      ballY[i] += ballSpeed;
    }
  }
}

void timer() { //used to add a delay between reaching zero lives and the end screen displaying
  if (frameCount%50==0) {
    timer++;
  }
}

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------//

void setup() {
  size(800, 600); 
  background(0); 
  smooth(); 
  noStroke(); 

  minim = new Minim(this);

  bgnmusic = minim.loadFile("bgnsong.mp3");
  bgnmusic.play();
  bgnmusic.loop();
  lasersound = minim.loadFile("lasersound.mp3");

  keys=new boolean[5]; // Represents each button input in its array (memory recorder)
  keys[0]=false; // all are false, since they are not pressed yet
  keys[1]=false; 
  keys[2]=false; 
  keys[3]=false;
  keys[4]=false;

  generateBullets(); // Start generating bullets
  generateBall();
  shipImage1();
  expImage();
  expImageZ();
  imageLoad();
}

void draw() {

  if (buttonPressed==false) {
    startScreen();
  } else {

    if (timer<2) {

      image(background, bgnX, bgnY-height);
      image(background, bgnX, bgnY);
      bgnY+=3;

      if (bgnY>height) {
        bgnY=0;
      }

      moveBullets();

      redrawGameField(); 

      shipImage2();

      text("Score: "+score, 650, 50);
      text("Lives: "+lives, 150, 50);

      moveBall();
      
      if (shipVisible) {

        checkCollision();
        checkShip();

        // move the ship when the LEFT or RIGHT arrow is pressed
        if (keys[0] && shipX < width - shipW ) {
          shipX = shipX + shipSpeed;
        }

        if (keys[1] && shipX > shipW) {
          shipX = shipX - shipSpeed;
        }
        // shut bullets when the SPACE BAR is pressed
        if (keys[2] && triggerReleased) { // When the SPACE bar is pressed shoot the current bullet
          lasersound.play();
          lasersound.rewind();
          triggerReleased = false;
          bulletX[currentBullet] = shipX; // the x and y coordinates of the ship as if the ship  
          bulletY[currentBullet] = shipY; // generates the bullets from its tip and turn the bullets
          bulletVisible[currentBullet] = true; // visible so they can be drawn on the screen
          currentBullet++; 
          if (currentBullet == 100) { // if 100 bullets are generated start back from 0
            currentBullet = 0;
            ballSpeed+=0.5;
          }
        }
        if (keys[2]==false) {
          triggerReleased = true;
        }
        if (keys[3] && shipY > 64) { //UP
          shipY = shipY - shipSpeed;
        }
        if (keys[4] && shipY < height-64) { //DOWN
          shipY = shipY + shipSpeed+3;
        }
      }
    }
  }
  if (lives==0) {
    expImageZ2();
    shipVisible = false;
    timer();
  }
  if (lives<0) {
    lives = 0;
  }
  if (timer==2) {
    endScreen();
  }
  if (keyPressed && key=='r') {
    buttonPressed = false;
    lives = 3;
    score = 0;
    timer = 0;
    shipVisible = true;
    currentFrame2 = 0;
  }
}

void mousePressed() {

  if (mouseX > 325 && mouseX < 475 && mouseY > 500 && mouseY < 550) {
    buttonPressed = true;
  }
}

void keyPressed() {
  // move the ship left / right with the arrow keys
  if (key==CODED && keyCode==RIGHT) keys[0]=true; 
  if (key==CODED && keyCode==LEFT)  keys[1]=true; 
  if (key==CODED && keyCode==UP) keys[3]=true;
  if (key==CODED && keyCode==DOWN) keys[4]=true;
  // shoot bullets when SPACE BAR is pressed
  if (key==' ') keys[2]=true;
}

void keyReleased() {
  if (key==CODED && keyCode==RIGHT) keys[0]=false; 
  if (key==CODED && keyCode==LEFT) keys[1]=false; 
  if (key==CODED && keyCode==UP) keys[3]=false;
  if (key==CODED && keyCode==DOWN) keys[4]=false;
  if (key==' ') keys[2]=false;
}