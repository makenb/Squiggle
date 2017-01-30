//---------------------------------------------------------------------------------------//
//                                                                                       //
// Squiggle by makenb@gmail.com                                                          //
// Mostly ripped directly from:                                                          //
// "Death to Sharpie" by Scott Cooper, Dullbits.com, <scottslongemailaddress@gmail.com>  //
//                                                                                       //
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

// Machine Constants in mm
final float   paper_size_x = 11 * 25.4; //25.4 mm/inch
final float   paper_size_y = 11 * 25.4;
final float   image_size_x = 10 * 25.4;
final float   image_size_y = 10 * 25.4;
final boolean var_spindle = true;
final boolean var_depth = false;
final int     max_pressure = 550;
final int     min_pressure = 450;
final int     safe_z = 1;
final int     max_z_depth = 5;
final int     max_feed = 4000;

// Super fun things to tweak. 
final int     half_radius = 3;          // How grundgy
final float   threshold = 18.5;           // threshold to stop the squiggle, difference in brightness from start to finish
final float   adjustbrightness = .25;     // How much to lighten already drawn areas
final float   brightness_cutout = 45.5;    // stop drawing if no more darkness 
final float   sharpie_dry_out = 0.05;   // Simulate the death of sharpie for screen, zero for super sharpie 
final String  pic_path = "pics/livrocks.jpg"; // Change backslash for Win

final int     squiggle_total = 10000;     // Total times to pick up the pen    //<---\
final int     squiggle_length = 10000;    // Too small will fry your servo     //<----\--- both of these are kind of deprecated

//Screen Globals
float    screen_scale;
float    screen_x = 1000;
float    screen_y = 1000;
float    steps_per_inch = screen_x/11;
float    x_old = 0;
float    y_old = 0;
float    zero_offset = steps_per_inch/2;
PImage   img;

//Squiggle Globals
float    darkest_x = 100;
float    darkest_y = 100;
float    darkest_value;
int      squiggle_count;
float    drawing_scale;
float    drawing_scale_x;
float    drawing_scale_y;
float    pressure_scale;

//Gcode Globals
float    drawing_min_x =  9999999;
float    drawing_max_x = -9999999;
float    drawing_min_y =  9999999;
float    drawing_max_y = -9999999;
boolean  is_pen_down;

PrintWriter OUTPUT;       // instantiation of the JAVA PrintWriter object.

///////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  size(1000, 1000, P2D);
  noSmooth();
  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, 100);  
  frameRate(120);
  
  OUTPUT = createWriter("output.gcode");
  pen_up();
  setup_squiggles();
  img.loadPixels();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void draw() {
    scale(1.0);
    random_darkness_walk();
  
    if (squiggle_count >= squiggle_total) {
        grid();
        dump_some_useless_stuff_and_close();
        noLoop();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void setup_squiggles() {
  img = loadImage(sketchPath("") + pic_path);  // Load the image into the program  
  img.loadPixels();
  
  screen_scale = min((screen_y-100)/img.height, (screen_x-100)/img.width);
  drawing_scale_x = image_size_x / img.width;
  drawing_scale_y = image_size_y / img.height;
  drawing_scale = min(drawing_scale_x, drawing_scale_y);
  pressure_scale = (max_pressure - min_pressure)/brightness_cutout;
  
  OUTPUT.println("(Block-name: Squiggle gcode Header)");
  OUTPUT.println("(Picture: " + pic_path + ")");
  OUTPUT.println("(Image dimensions: " + img.width + " by " + img.height + ")");
  OUTPUT.println("(adjustbrightness: " + adjustbrightness + ")");
  OUTPUT.println("(squiggle_total: " + squiggle_total + ")");
  OUTPUT.println("(squiggle_length: " + squiggle_length + ")");
  OUTPUT.println("(Paper size: " + nf(paper_size_x,0,2) + " by " + nf(paper_size_y,0,2) + "      " + nf(paper_size_x/25.4,0,2) + " by " + nf(paper_size_y/25.4,0,2) + ")");
  OUTPUT.println("(Max image size: " + nf(image_size_x,0,2) + " by " + nf(image_size_y,0,2) + "      " + nf(image_size_x/25.4,0,2) + " by " + nf(image_size_y/25.4,0,2) + ")");
  OUTPUT.println("(Calc image size " + nf(img.width * drawing_scale,0,2) + " by " + nf(img.height * drawing_scale,0,2) + "      " + nf(img.width * drawing_scale/25.4,0,2) + " by " + nf(img.height * drawing_scale/25.4,0,2) + ")");
  OUTPUT.println("(Drawing scale: " + drawing_scale + ")");
  OUTPUT.println("(Screen Scale: " + screen_scale + ")");
  OUTPUT.println("(gcode here)");
}

 
///////////////////////////////////////////////////////////////////////////////////////////////////////
void grid() {
  // This will give you a rough idea of the size of the printed image, in inches.
  // Some screen scales smaller than 1.0 will sometimes display every other line
  // It looks like a big logic bug, but it just can't display a one pixel line scaled down well.
  stroke(0, 50, 100, 30);
  for (float xy = -zero_offset; xy <= 1000; xy+=steps_per_inch) {
    line(xy, 0, xy, 2000);
    line(0, xy, 2000, xy );
  }

  stroke(0, 100, 100, 50);
  line(zero_offset, 0, zero_offset, 2000);
  line(0, screen_y-zero_offset, 2000, screen_x-zero_offset);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void dump_some_useless_stuff_and_close() {
  //gcode footer:
  OUTPUT.println("(Block-name: Squiggle Gcode Footer)");
  OUTPUT.println("M05 \nG0 X0 Y0 Z5");
  println ("Some Gcode Stats: ");
  println ("Min X: " + drawing_min_x + " Max X " + drawing_max_x);
  println ("Min Y: " + drawing_min_y + " Max Y " + drawing_max_y);
  OUTPUT.flush();
  OUTPUT.close();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////