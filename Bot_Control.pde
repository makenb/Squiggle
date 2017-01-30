///////////////////////////////////////////////////////////////////////////////////////////////////////
// No, it's not a fancy dancy class like the snot nosed kids are doing these days.
// Now get the hell off my lawn.
///////////////////////////////////////////////////////////////////////////////////////////////////////
void pen_up() {
  String buf = "M05 \nG1 Z" + safe_z;
  is_pen_down = false;
  OUTPUT.println(buf);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void pen_down(float s_val) {
  String buf = "M03 S" + nf((s_val), 0, 2) + "\nG1 Z0" + " F" + max_feed; //My Bot uses spindle speed to control pen pressure
  is_pen_down = true;
  OUTPUT.println(buf);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void move_abs(float x, float y) {
  String buf;
  if (is_pen_down){
    buf = "G1 X" + nf((x*drawing_scale), 0, 4) + " Y" + nf((y*drawing_scale), 0, 4);
  } else {
    buf = "(Block-name: Squiggle" + squiggle_count + ")\n" + "G0 X" + nf((x*drawing_scale),0,4) + " Y" + nf((y*drawing_scale),0,4);
  }

  if (x < drawing_min_x) { drawing_min_x = x; }
  if (x > drawing_max_x) { drawing_max_x = x; }
  if (y < drawing_min_y) { drawing_min_y = y; }
  if (y > drawing_max_y) { drawing_max_y = y; }
  
  if (is_pen_down) {  //This is only for on screen display
    stroke(0, 100, 0, 100-(squiggle_count * sharpie_dry_out));
    line((x_old * screen_scale)+zero_offset,(screen_y - (y_old * screen_scale))-zero_offset , (x * screen_scale)+zero_offset, (screen_y - (y * screen_scale))-zero_offset);
  }
  
  x_old = x;
  y_old = y;
  OUTPUT.println(buf);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////