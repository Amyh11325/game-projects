/* Doodle Jump
 * Based off the mobile game Doodle Jump
 * Bounce off platforms to reach higher heights and scores
 * Runs using Java and Processing (latter is downloaded separately)
 * Uses sprite sheets and background images from Doodle Jump
 * Code created Summer 2018 by Amy He
 */
import processing.core.*;

public class DoodleJump extends PApplet {
	PImage bg; 			// for background
	Platform[] plats; 	// platforms
	Lik lik; 			// player character: that weird green thing
	int score; 			// arbitrary measure of height traveled by player
	public final static int NUMPLATS = 10; // number of platforms on screen at a time
	boolean play; 		// if play true, a game is in progress
	public final int likSpeed = 6; // how fast lik can move left or right

	public static void main(String[] args) {
		PApplet.main("DoodleJump");
	}

	// called once at start of program
	// loads and sizes background image
	public void settings() {
		bg = loadImage("doodleJumpSprites/bck.png");
		bg.resize(0, 650);
		size(bg.width, bg.height);
	}

	// called automatically once at start of program
	// also called to reset game
	public void setup() {
		// sets background
		background(bg);

		play = false;
		textSize(30);
		fill(0);

		// creates and places player character
		lik = new Lik(width / 2, height / 3 * 2, 0.2, this);
		lik.display();

		// create platforms
		plats = new Platform[NUMPLATS];
		// places one platform under lik at the start
		plats[0] = new Platform(width / 2, (int) (height * 0.95), this);
		plats[0].speed = 0;
		plats[0].display();
		// creates more random platforms above lik
		// these platforms are spaced evenly on purpose so that lik has a lower chance
		// of getting stuck
		for (int i = 1; i < NUMPLATS; i++) {
			plats[i] = new Platform((int) (Math.random() * (width - plats[0].img.width)), height / NUMPLATS * i, this);
			plats[i].display();
		}

		score = 0;
	}

	public void draw() {
		if (play) {
			background(bg);

			// move lik left or right
			if (keyPressed) {
				if (key == CODED) {
					if (keyCode == LEFT) {
						lik.moveLeft();
					} else if (keyCode == RIGHT) {
						lik.moveRight();
					}
				}
			}

			// move like up or down
			lik.update(plats);

			lik.display();

			// move platforms
			for (int i = 0; i < plats.length; i++) {
				// if lik moves upward and is in the upper half of the screen,
				// scroll the platforms down to make it seem like lik is moving up
				if (lik.v.y < 0 && lik.loc.y < height / 2) {
					plats[i].moveDown(-lik.v.y);
					// update score
					score += -lik.v.y;

					// if a platform moves out of bounds (below the visible screen),
					// remove it and add a new one above the screen
					if (plats[i].y > height) {
						plats[i] = new Platform((int) (Math.random() * (width - plats[0].img.width)),
								(int) (Math.random() * 6 - 50), this);
					}

				}

				plats[i].update();
				plats[i].display();
			}

			// if lik is moving up and is in the upper half of the screen,
			// do not move lik
			if (lik.v.y < 0 && lik.loc.y < height / 2) {
				lik.loc.y -= lik.v.y;
			}

			// Check for game over (lik below the visible screen)
			if (lik.loc.y > height) {
				text("Game Over", height / 3 - 40);
				text("Score: " + score / 100, height / 3);
				text("Click To Restart", height / 3 + 40);
			} else {
				// display score
				text((score / 100) + "", 30);
			}

		} else {
			text("Click To Play", height / 3);
			text("Keys: Left and Right Arrows", height * 2 / 5);
		}
	}

	// centers text automatically
	public void text(String s, int h) {
		text(s, width / 2 - textWidth(s) / 2, h);
	}

	// if mouse is pressed, start or restart game
	public void mousePressed() {
		if (play) {
			setup();
		} else {
			play = true;
		}
	}

	class Platform {
		// x: x-position
		// start: stores starting position of platform based on "horiz"
		// range: how far the platform moves
		// speed: how fast the platform moves; if equals 0, platform won't move
		int x, start, range, speed;	
		float y;						// y-position
		boolean horiz;					// true: platform moves horizontally, false: moves vertically
		PImage img;						// image of the platform
		PApplet parent;					// to access the applet

		Platform(int x, int y, PApplet p) {
			this.x = x;
			this.y = y;
			horiz = Math.random() < 0.5;
			start = horiz ? x : y;
			parent = p;
			range = (int) (Math.random() * 20 + 60);
			speed = (int) (Math.random() * 7 - 3.5);
			// loads image of platform from sprite sheet
			img = loadImage("doodleJumpSprites/game-tiles.png").get(0, 0, 58, 16);
		}

		public void update() {
			// moves platform
			if (horiz) {
				x += speed;
			} else {
				y += speed;
			}
			
			// if platform reaches the end of its range, reverse direction
			if (horiz ? Math.abs(start - x) > range : Math.abs(start - y) > range) {
				speed = -speed;
				if (!horiz)
					y = start - (range) * Math.abs(start - y) / (start - y);
				else
					x = start - (range) * Math.abs(start - x) / (start - x);
			}
		}

		// moves platform down
		public void moveDown(float shift) {
			y += shift;
			if (!horiz)
				start += shift;
		}

		public void display() {
			image(img, x, y);
		}
	}

	class Lik {
		PVector loc, v, g; 		// location, velocity, gravity
		PImage img = loadImage("doodleJumpSprites/lik.png").get(10, 0, 210, 210);	// load lik's image from sprite sheet
		PApplet parent;			// to access applet
		final int speed = 4;	// lik's left and right speed

		Lik(int locX, int locY, double gY, PApplet p) {
			loc = new PVector(locX, locY);
			v = new PVector(0, 0);
			g = new PVector(0, (float) 0.3);
			img.resize(60, 0);
			parent = p;
		}

		public void moveLeft() {
			loc.x -= speed;
		}

		public void moveRight() {
			loc.x += speed;
		}

		// update lik's position
		public void update(Platform[] plats) {
			// update lik's vertical position and velocity
			loc.add(v);
			v.add(g);
			
			// check if lik lands on a platform, if he does bounce him up
			for (int i = 0; i < plats.length; i++) {
				if (v.y > 0 && loc.y + img.height < plats[i].y + plats[i].img.height && loc.y + img.height > plats[i].y
						&& loc.x + 2 * img.width / 3 > plats[i].x && loc.x <= plats[i].x + plats[i].img.width) {
					v.y = -10;
				}
			}
		}

		public void display() {
			image(img, loc.x, loc.y);
			
			// allows lik to loop from one side of the screen to the other
			// Note: doesn't affect lik's hitbox until he is only partially on one side of the screen
			if (loc.x < 0) {
				image(img, loc.x + parent.width, loc.y);
				if (loc.x < -img.width) {
					loc.x = parent.width - img.width;
				}
			}
			if (loc.x + img.width > parent.width) {
				image(img, loc.x - parent.width, loc.y);
				if (loc.x > parent.width) {
					loc.x = 0;
				}
			}
		}
		
	}
}
