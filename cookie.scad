// Pottery Stamp Generator

// Parameters for customization
height = 40;           // Height of each extrusion set
base_thickness = 4;    // Thickness of the connecting plate
outline_offset = 10;   // Distance from original SVG outline for the base plate
steps = 6;             // Number of steps in the extrusion
step_height = 5;       // Height of each step
scale_factor = 0.005;  // How much to scale each step
svg_file = "final_image.svg"; // Input SVG file

desired_width = 100;   // Desired width of the SVG in mm (before the overall scale)

// Main stamp body
scale([2, 2, 1]) {
  // Top face extrusions
  extruded_shape(steps, step_height, scale_factor, height, svg_file, desired_width);
  extruded_shape(steps, step_height, scale_factor * -1, height, svg_file, desired_width);
  
  // Base plate using the SVG shape with offset
  color("Crimson") {
  translate([0, 0, height]) {
    linear_extrude(height = base_thickness) {
      offset(r = outline_offset) {
        resize([desired_width, 0], auto=true) { // Set width, auto-scale height
          import(svg_file, center = true);
        }
      }
    }
  }
  }
  
  // Bottom face extrusions (mirrored)
  rotate([180, 0, 0]) {
    translate([0, 0, -(height * 2 + base_thickness)]) {
      mirror([0, 1, 0]) {
        extruded_shape(steps, step_height, scale_factor, height, svg_file, desired_width);
        extruded_shape(steps, step_height, scale_factor * -1, height, svg_file, desired_width);
      }
    }
  }
}

// Modified module with width parameter
module extruded_shape(num_steps, step_height, scale_factor, max_height, svg_path, width) {
  for(i = [0 : num_steps - 1]) {
    step_scale = 1 + (scale_factor * i);
    translation = i * step_height;
    
    scale([step_scale, step_scale, 1]) {
      translate([0, 0, translation]) {
        linear_extrude(height = max_height - translation) {
          resize([width, 0], auto=true) { // Set width, auto-scale height
            import(svg_path, center = true);
          }
        }
      }
    }
  }
}
