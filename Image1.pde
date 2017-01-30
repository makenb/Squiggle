///////////////////////////////////////////////////////////////////////////////////////////////////////
//  Mostly a find darkest within radius and move there, kind of thing.
///////////////////////////////////////////////////////////////////////////////////////////////////////
void random_darkness_walk() {
  float x, y;
  float last_darkest;
  float darkest_neighbor;
  float   pen_pressure = max_pressure;
  
  find_darkest();
  if (brightness_cutout < darkest_value){
    squiggle_count = squiggle_total;
    return;
  }
  x = darkest_x;
  y = darkest_y;
  last_darkest = darkest_value;
  if (var_spindle){
      pen_pressure = (max_pressure - (darkest_value * pressure_scale));
    }
  squiggle_count++;
  
  //find_darkest_neighbor(x, y);// Not sure why this is necessary?
  move_abs(darkest_x , (img.height - darkest_y));
  pen_down(pen_pressure);
  
  for (int s = 0; s < squiggle_length; s++) {
    darkest_neighbor = find_darkest_neighbor(x, y);
    if (darkest_neighbor > (last_darkest + threshold * random(100))) { //<-have to experiment with this
      s = squiggle_length;
    }
    lighten(adjustbrightness, darkest_x, darkest_y);
    move_abs(darkest_x , (img.height - darkest_y));
    x = darkest_x;
    y = darkest_y;    
    }

  pen_up();
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
float find_darkest_neighbor(float start_x, float start_y) {
  float darkest_neighbor = 256;
  float min_x, max_x, min_y, max_y;
  
  min_x = constrain(start_x - half_radius, half_radius, img.width  - half_radius);
  min_y = constrain(start_y - half_radius, half_radius, img.height - half_radius);
  max_x = constrain(start_x + half_radius, half_radius, img.width  - half_radius);
  max_y = constrain(start_y + half_radius, half_radius, img.height - half_radius);
  
  // One day I will test this to see if it does anything close to what I think it does.
  for (float x = min_x; x <= max_x; x++) {
    for (float y = min_y; y <= max_y; y++) {
      // Calculate the 1D location from a 2D grid
      int loc = int(x + y*img.width);
      float d = dist(start_x, start_y, x, y);
      if (d <= half_radius) {
        float r = brightness (img.pixels[loc]) + random(0.01);  // random else you get ugly horizontal lines
        if (r <= darkest_neighbor) {
          darkest_x = x;
          darkest_y = y;
          darkest_neighbor = r;
        }
      }
    }
  }
return darkest_neighbor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void find_darkest() {
  darkest_value = 256;
  for (int x = half_radius; x < img.width - half_radius; x++) {
    for (int y = half_radius; y < img.height - half_radius; y++ ) {
      // Calculate the 1D location from a 2D grid
      int loc = x + y*img.width;
      
      float r = brightness (img.pixels[loc]);
      if (r < darkest_value) {
        darkest_x = x;
        darkest_y = y;
        darkest_value = r;
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void lighten(float adjustbrightness, float start_x, float start_y) {
  /*int min_x, max_x, min_y, max_y;

  min_x = constrain(start_x - half_radius, half_radius, img.width  - half_radius);
  min_y = constrain(start_y - half_radius, half_radius, img.height - half_radius);
  max_x = constrain(start_x + half_radius, half_radius, img.width  - half_radius);
  max_y = constrain(start_y + half_radius, half_radius, img.height - half_radius);
  
  
  for (int x = min_x; x <= max_x; x++) {
    for (int y = min_y; y <= max_y; y++) {
      float d = dist(start_x, start_y, x, y);
      if (d <= half_radius) {
        // Calculate the 1D location from a 2D grid
        int loc = y*img.width + x;
        float r = red (img.pixels[loc]);
        r += adjustbrightness / d;
        r = constrain(r,0,255);
        color c = color(r);
        img.pixels[loc] = c;
      }
    }
  }
  */

  // Hey boys and girls its thedailywtf.com time, yeah.....
  lighten_one_pixel(adjustbrightness * 40, start_x, start_y);

  lighten_one_pixel(adjustbrightness * random(16), start_x + 1, start_y    );
  lighten_one_pixel(adjustbrightness * random(16), start_x - 1, start_y    );
  lighten_one_pixel(adjustbrightness * random(16), start_x    , start_y + 1);
  lighten_one_pixel(adjustbrightness * random(16), start_x    , start_y - 1);

  lighten_one_pixel(adjustbrightness * random(6), start_x + 1, start_y + 1);
  lighten_one_pixel(adjustbrightness * random(6), start_x - 1, start_y - 1);
  lighten_one_pixel(adjustbrightness * random(6), start_x - 1, start_y + 1);
  lighten_one_pixel(adjustbrightness * random(6), start_x + 1, start_y - 1);
  
  //lighten_one_pixel(adjustbrightness * 2, start_x + 2, start_y - 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x + 2, start_y - 1);
  lighten_one_pixel(adjustbrightness * random(2), start_x + 2, start_y    );
  lighten_one_pixel(adjustbrightness * random(2), start_x + 2, start_y + 1);
  //lighten_one_pixel(adjustbrightness + 2, start_x + 2, start_y + 2);
  
  //lighten_one_pixel(adjustbrightness * 2, start_x - 2, start_y - 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x - 2, start_y - 1);
  lighten_one_pixel(adjustbrightness * random(2), start_x - 2, start_y    );
  lighten_one_pixel(adjustbrightness * random(2), start_x - 2, start_y + 1);
  //lighten_one_pixel(adjustbrightness + 2, start_x - 2, start_y + 2);
  
  //lighten_one_pixel(adjustbrightness + 2, start_x - 2, start_y - 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x - 1, start_y - 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x    , start_y - 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x + 1, start_y - 2);
  //lighten_one_pixel(adjustbrightness + 2, start_x + 2, start_y - 2);
  
  //lighten_one_pixel(adjustbrightness * 2, start_x - 2, start_y + 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x - 1, start_y + 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x    , start_y + 2);
  lighten_one_pixel(adjustbrightness * random(2), start_x + 1, start_y + 2);
  //lighten_one_pixel(adjustbrightness * 2, start_x + 2, start_y + 2);
  
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void lighten_one_pixel(float adjustbrightness, float x, float y) {
  int loc = int((y)*img.width + x);
  float r = brightness (img.pixels[loc]);
  r += adjustbrightness;
  r = constrain(r,0,255);
  color c = color (0, 0,r);
  img.pixels[loc] = c;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////