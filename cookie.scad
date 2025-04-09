// OpenSCAD script to create a cookie stamp with a pattern from an SVG file

inch = 25.4;
$fn = 20; // Control curve tessellation to reduce geometry

// Stamp output dimensions (not counting the baseplate)
depth = 0.3 * inch;     // Height of the stamp
width = 2 * inch;       // Desired width of the SVG in mm

// Baseplate dimensions
base_offset = 0.25 * inch; // How far the outline is from the edge of the SVG
base_depth = 0.10 * inch; // Depth of the connecting plate
base = true;               // Whether to include the baseplate in the output

// SVG sizing
svg_base_offset = 0.0625 * inch; // How much larger SVG shape is where it meets the baseplate
fixed_steps = 10;         // Fixed number of steps
svg_file = "pattern.svg"; // Input SVG file

// Import the SVG just once and store as a module
module svg_shape() {
  resize([width, 0], auto=true) {
    import(svg_file, center = true);
  }
}

// Base plate using the SVG shape with offset
if (base == true) {
  color("LightGray") {
    linear_extrude(height = base_depth, convexity = 10) {
      offset(r = base_offset) {
        svg_shape();
      }
    }
  }
}

// Top face extrusions - single bevelled extrusion for optimal geometry
color("LightGreen") {
  rotate([180, 0, 0]) {
    translate([0, 0, -((base == true) ? depth + base_depth : depth)]) {
      mirror([0, 1, 0]) {
        bevelled_svg();
      }
    }
  }
}

module bevelled_svg() {
    step_height = depth / fixed_steps;
    
    // Single pass with optimized steps
    for (i = [0 : fixed_steps - 1]) {
        // Linearly interpolate the offset radius
        step_offset = (i / (fixed_steps - 1)) * svg_base_offset;
        translation = i * step_height; // Start at 0 and increment by step_height
        
        // Create thicker layers with better convexity settings
        translate([0, 0, translation]) {
            linear_extrude(height = step_height, convexity = 10) {
                offset(r = step_offset) {
                    svg_shape();
                }
            }
        }
    }
}
