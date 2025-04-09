// OpenSCAD script to create a cookie stamp with a pattern from an SVG file

inch = 25.4;

height = 1 * inch;     // Height of the stamp

base_thickness = 10;    // Thickness of the connecting plate
outline_offset = 10;   // Distance from original SVG outline for the base plate
steps = 10;             // Reduced number of steps (can increase once working)
step_height = 5;       // Height of each step
scale_factor = 0.005;  // How much to scale each step
svg_file = "pattern.svg"; // Input SVG file

desired_width = 2 * inch;   // Desired width of the SVG in mm

// Import the SVG just once and store as a module
module svg_shape() {
  resize([desired_width, 0], auto=true) {
    import(svg_file, center = true);
  }
}

// Base plate using the SVG shape with offset
color("LightGray") {
  translate([0, 0, 0]) {
    linear_extrude(height = base_thickness) {
      offset(r = outline_offset) {
        svg_shape();
      }
    }
  }
}

// Top face extrusions
color("LightGreen") {
  rotate([180, 0, 0]) {
    translate([0, 0, -(height + base_thickness)]) {
      mirror([0, 1, 0]) {
        extruded_shape(steps, step_height, scale_factor, height);
        extruded_shape(steps, step_height, scale_factor * -1, height);
      }
    }
  }
}

// Modified module to use the predefined SVG shape
module extruded_shape(num_steps, step_height, scale_factor, max_height) {
  for(i = [0 : num_steps - 1]) {
    step_scale = 1 + (scale_factor * i);
    translation = i * step_height;
    
    scale([step_scale, step_scale, 1]) {
      translate([0, 0, translation]) {
        linear_extrude(height = max_height - translation) {
          svg_shape();
        }
      }
    }
  }
}
