// OpenSCAD script to create a curved cookie stamp with a pattern from an SVG file
inch = 25.4;
$fn = 60; // Increased for smoother curves

// Debug mode
debug = true;  // Set to true to show debug geometries

// Stamp output dimensions
depth = 0.3 * inch;     // How tall the stamp is (how much it cuts into the dough)
width = 2 * inch;       // Width of the stamp (this is the width along the curve)
length = 2 * inch;      // Length/depth of the stamp (orthogonal to the curve)

// SVG details
svg_file = "sheep.svg"; // Input SVG file

// Curve parameters
curve_angle = 60;          // Angle of curvature in degrees
curve_radius = 3 * inch;   // Radius of the arc

// Number of slices
num_slices = 20;

// Module to import SVG once - resized to fill the specified width
module full_svg() {
  resize([width, 0], auto=true) {
    import(svg_file, center=true);
  }
}

// Module to get a slice of the SVG with adjusted width
module svg_slice(slice_num, total_slices) {
  // Calculate the slice's position and width
  // Standard slice width (if it were flat)
  slice_width = width / total_slices;
  // Calculate where this slice starts along the x-axis 
  offset_x = -width/2 + slice_num * slice_width;
  
  // Create a slice of the SVG by intersecting with a mask
  intersection() {
    // Full SVG already resized
    full_svg();
    
    // Create a mask for this slice - centered at the slice's center
    translate([offset_x + slice_width/2, 0, 0])
    square([slice_width, length * 2], center=true);
  }
}

// Module to arrange a slice along the arc
module curved_slice(slice_num, total_slices) {
  // Calculate the angle for each slice based on the arc length
  // This ensures slices are evenly spaced along the arc
  slice_angle = curve_angle / total_slices;
  
  // Calculate the center angle for this particular slice
  current_angle = -curve_angle/2 + slice_num * slice_angle + (slice_angle/2);
  
  // Position the slice correctly on the cylinder surface
  translate([0, 0, -curve_radius - depth])  // Move to cylinder center
  rotate([0, current_angle, 0])     // Rotate to correct angle
  translate([0, 0, curve_radius])   // Move back to cylinder surface
  
  // Create the extruded slice
  linear_extrude(height=depth)
  svg_slice(slice_num, total_slices);
}

// Debug visualization for the sphere and arc center
module debug_geometry() {
  // Sphere center position
  translate([0, 0, -curve_radius]) {
    // Mark the center of the sphere
    color("red") sphere(r=5);
    
    // Semi-transparent sphere with the correct radius
    color([0.5, 0.5, 0.9, 0.3])
    rotate([90, 0, 0])  // Rotate to correct plane
    cylinder(h=width, r=curve_radius - depth, center=true);
  }
}

// Conditional display based on debug mode
if (debug == true) {
  // Show the flat SVG slices for reference
  for (i = [0:num_slices-1]) {
    color([i/num_slices, 0, 1-i/num_slices, 0.7])
    linear_extrude(height=5)
    svg_slice(i, num_slices);
  }
  /*
  */

  // Add the debug geometry
  debug_geometry();
}

// Create the entire curved stamp
for (i = [0:num_slices-1]) {
  color([i/num_slices, 0, 1-i/num_slices])
  curved_slice(i, num_slices);
}
