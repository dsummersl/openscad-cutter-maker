// OpenSCAD script to create a cookie stamp with a pattern from an SVG file

inch = 25.4;

// total output dimensions - note that the height cannot be controlled as we don't know the SVG's dimensions.
depth = 0.5 * inch;     // Height of the stamp
width = 2 * inch;   // Desired width of the SVG in mm

// Baseplate dimensions
base_offset = 0.25 * inch; // How far the outline is from the edge of the SVG
base_depth = 0.125 * inch;    // Depth of the connecting plate

// SVG sizing
svg_base_offset = 0.0625 * inch; // How much larer SVG shape is where it meets the baseplate.
scale_factor = 0.05;  // How much to grow each at each step from the top of the svg to the baseplate
svg_file = "pattern.svg"; // Input SVG file


// Import the SVG just once and store as a module
module svg_shape() {
  resize([width, 0], auto=true) {
    import(svg_file, center = true);
  }
}

// Base plate using the SVG shape with offset
color("LightGray") {
  translate([0, 0, 0]) {
    linear_extrude(height = base_depth) {
      offset(r = base_offset) {
        svg_shape();
      }
    }
  }
}

// Top face extrusions
color("LightGreen") {
  rotate([180, 0, 0]) {
    translate([0, 0, -depth]) {
      mirror([0, 1, 0]) {
        bevelled_svg(scale_factor);
        bevelled_svg(scale_factor * -1);
      }
    }
  }
}

module bevelled_svg(scale_factor) {
    num_steps = ceil(abs(svg_base_offset / scale_factor));
    step_height = (depth - base_depth) / num_steps;

    for (i = [0 : num_steps - 1]) {
        // Linearly interpolate the offset radius
        step_offset = (i / (num_steps - 1)) * svg_base_offset;
        translation = i * step_height + base_depth;

        translate([0, 0, translation]) {
            linear_extrude(height = step_height) {
                offset(r = step_offset) {
                    svg_shape();
                }
            }
        }
    }
}
