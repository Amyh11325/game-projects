/* PongPong
 * Based off an actual game called PongPong on the Internet
 * Classic Pong but every time the ball hits a paddle it splits into two
 * Runs using Java and Processing (latter is downloaded separately)
 * Code created Summer 2018 by Amy He
 */

import processing.core.*;
import java.util.*;

public class PongPong extends PApplet {
	Paddle left, right; 							// controllable left and right rectangular paddles
	boolean play; 									//if play true game is occurring
	boolean[] keys = new boolean[4]; 				//for keyboard input
	int LScore, RScore; 							//scores
	ArrayList<Ball> balls = new ArrayList<Ball>(); 	// will contain square "balls"

	public static void main(String[] args) {
		PApplet.main("PongPong");
	}

	
	//called once at beginning
	public void settings() {
		size(1200, 600);
		left = new Paddle(this, 'L');
		right = new Paddle(this, 'R');
	}
	
	//called automatically at beginning once
	public void setup() {
		play = false;
		noStroke();
		textSize(30);
		cursor(CROSS);
		
		//create first ball
		//position is at center of screen, whether it goes left or right is random,
		//initial vertical speed is random, but cannot be 0
		double ySpeed = Math.random() * 9 - 4.5;
		balls.add(new Ball(this, width / 2 - width / 125 / 2, height / 2 - height / 65 / 2,
				Math.random() < 0.5 ? -4 : 4, ySpeed == 0 ? 1.8 : ySpeed));
		
		//initialization for keyboard input
		for (int i = 0; i < keys.length; i++) {
			keys[i] = false;
		}
		
		//draws background and text
		initialBackground();
		outlinedText("Click To Play", height/4);
		outlinedText("Left Player's Keys: W and S", height * 12 / 15);
		outlinedText("Right Player's Keys: O and L", height * 13 / 15);
		
		// displays winner if a game was finished
		if (LScore != 0 || RScore != 0) {
			if (LScore > RScore)
				outlinedText("Left Player Wins", height/3 + 40);
			else if (RScore > LScore)
				outlinedText("Right Player Wins", height/3 + 40);
			else
				outlinedText("Tie", height/3 + 40);
		}
		
		LScore = 0;
		RScore = 0;
	}
	
	//adds slight bottom right shadow to text
	public void outlinedText(String t, int h) {
		fill(75);
		text(t, width/2 - textWidth(t)/2 -2, h + 2);
		fill(255);
		text(t, width/2 - textWidth(t)/2 -4, h);
	}

	
	//backbone of program, called on a loop
	public void draw() {
		if (play) {
			// keyboard input for controlling paddles
			if (keys[0])
				left.moveUp();
			if (keys[1])
				left.moveDown();
			if (keys[2])
				right.moveUp();
			if (keys[3])
				right.moveDown();
			
			//updates balls
			for (int i = balls.size() - 1; i >= 0; i--) {
				balls.get(i).moveBall(right, left);
				
				//removes balls that are out of bounds and updates score
				if (balls.get(i).outOfBounds(right, left) && !balls.get(i).hitsPaddle(right, left)) {
					if (balls.get(i).getX() < width / 2) {
						RScore++;
					} else {
						LScore++;
					}
					balls.remove(i);
				//reflects balls that hit paddles and adds an extra ball
				} else if (balls.get(i).outOfBounds(right, left) && balls.get(i).hitsPaddle(right, left)) {
					balls.add(balls.get(i).getNewBall(right, left));
					balls.add(balls.get(i).getNewBallSame(right, left));
					balls.remove(i);
				}
			}
			
			//update the screen display
			initialBackground();
			
			// if there are no more balls, end the game and
			//call setup() to display winner and prepare next game
			if (balls.size() == 0) {
				play = false;
				setup();
			}
		}
	}
	
	// if mouse pressed start the game
	public void mousePressed() {
		play = true;
	}
	
	// these three methods records which keys are being pressed
	public void keyPressed() {
		setKeys(true);
	}
	public void keyReleased() {
		setKeys(false);
	}
	public void setKeys(boolean p) {
		if (key == 119)
			keys[0] = p;
		else if (key == 115)
			keys[1] = p;
		else if (key == 111)
			keys[2] = p;
		else if (key == 108)
			keys[3] = p;
	}
	

	// for creating/updating background with score, balls, paddles, center line
	public void initialBackground() {
		// displays black background
		background(0);
		color(255, 255, 255);

		// displays center dotted line
		for (int i = 15; i < height; i += height / 12) {
			rect(width / 2 - width / 800, i, width / 400, height / 20);
		}

		// displays all balls
		for (int i = 0; i < balls.size(); i++) {
			balls.get(i).display();
		}

		// displays score
		text(RScore, 3 * width / 4, height / 10);
		text(LScore, width / 4, height / 10);

		// displays paddles
		left.display();
		right.display();
	}
}

class Paddle {
	int x, y, h, w; //position, height, and width
	PApplet parent; //to access the applet screen
	int speed;      //how fast the paddles move

	Paddle(PApplet parent, char side) {
		this.parent = parent;
		w = parent.width / 120;
		h = parent.height / 6;
		y = parent.height / 2 - h / 2;
		speed = parent.height / 70;
		
		//controls which side the paddle is on
		if (side == 'L') {
			x = parent.width / 80;
		} else {
			x = parent.width - parent.width / 80 - w;
		}
	}

	void display() {
		parent.rect(x, y, w, h);
	}

	void moveDown() {
		if (y + speed + h <= parent.height) {
			y += speed;
		} else {
			y = parent.height - h;
		}
	}

	void moveUp() {
		if (y - speed >= 0) {
			y -= speed;
		} else {
			y = 0;
		}
	}
}

class Ball {
	double x, y;	//position
	double YSpeed;	//vertical speed
	double XSpeed;	//horizontal speed
	static int h, w;//height and width
	PApplet parent;	//access to applet screen

	Ball(PApplet parent, double x, double y, double XSpeed, double YSpeed) {
		this.parent = parent;
		this.YSpeed = YSpeed;
		this.XSpeed = XSpeed;
		w = parent.width / 125;
		h = parent.height / 65;
		
		if (x < parent.width / 3) {
			XSpeed = -XSpeed;
		}
		this.x = x;
		this.y = y;
	}

	void display() {
		parent.rect((int) x, (int) y, w, h);
	}

	void moveBall(Paddle Rp, Paddle Lp) {
		//if ball hits the top or bottom of the screen, it bounces
		if (y < 0 || y > parent.height - h) {
			YSpeed = -YSpeed;
		}
		
		x += XSpeed;
		y += YSpeed;
	}

	// returns true if center of ball is in front of a paddle 
	//and on the same side of the screen as that paddle
	boolean hitsPaddle(Paddle Rp, Paddle Lp) {
		return (y + h / 2 >= Lp.y && y + h / 2 <= Lp.y + Lp.h && x < parent.width / 2)
				|| (y + h / 2 >= Rp.y && y + h / 2 <= Rp.y + Rp.h && x > parent.width / 2);
	}

	//returns true if ball is past either paddle
	boolean outOfBounds(Paddle Rp, Paddle Lp) {
		return x + w > Rp.x || x < Lp.x + Lp.w;
	}

	//returns ball with different vertical speed and higher horizontal speed, also a mess 
	Ball getNewBall(Paddle Rp, Paddle Lp) {
		// if vertical speed is too low, increases it
		if (Math.abs(YSpeed) < 0.5) {
			YSpeed += 1.5 * YSpeed / Math.abs(YSpeed);
		}
		
		//adjustable, controls how different the speeds of the new balls are
		double temp1 = Math.random() * 4 + 4;
		double temp2 = Math.random() * 4 + 5;
		
		if (x < parent.width / 2) {
			return new Ball(parent, Lp.x + Lp.w, y, -(XSpeed + XSpeed / temp1),
					YSpeed + YSpeed / temp2);
		} else {
			return new Ball(parent, Rp.x - w, y, -(XSpeed + XSpeed / temp1), YSpeed + YSpeed
					/ temp2);
		}
	}

	//returns mostly the same ball with reflected horizontal speed and slightly different vertical speed
	Ball getNewBallSame(Paddle Rp, Paddle Lp) {
		if (x < parent.width / 2) {
			//last part is supposed to vary YSpeed based on where the ball hits the paddle (may need calibration)
			return new Ball(parent, Lp.x + Lp.w, y, -XSpeed, YSpeed + YSpeed * (y - Lp.y + Lp.h / 2.0) / 200.0); 
		} else {
			return new Ball(parent, Rp.x - w, y, -XSpeed, YSpeed - YSpeed * (y - Rp.y + Rp.h / 2.0) / 200.0);
		}
	}

	double getX() {
		return x;
	}
}