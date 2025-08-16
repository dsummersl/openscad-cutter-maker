from invoke import task
import os
import shutil


OPENSCAD_PATH = os.environ.get("OPENSCAD_PATH", "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD")


@task
def svg(
    c,
    input_image="input.png"
):
    """Convert an image to SVG and generate a 3D model STL file"""
    temp_dir = ".temp"
    base_name = os.path.splitext(os.path.basename(input_image))[0]
    output_svg = os.path.join(os.getcwd(), f"{base_name}.svg")

    # Create temporary directory if it doesn't exist
    os.makedirs(temp_dir, exist_ok=True)

    print(f"Converting {input_image} to SVG...")
    cutoff = 80  # Threshold for LUT filter
    blur_radius = "1:1"  # Boxblur radius
    scale_width = 500  # Output image width
    filters = f"format=gray,boxblur={blur_radius},erosion,lut='if(gt(val,{cutoff}),0,255)',sobel,lut='if(gt(val,{cutoff}),0,255)',scale={scale_width}:-1"

    c.run(
        f"ffmpeg -i {input_image} -vf \"{filters}\" -update 1 {temp_dir}/scaled-grayscale.png",
        echo=True,
    )
    c.run(f"convert {temp_dir}/scaled-grayscale.png {temp_dir}/scaled-grayscale.pnm", echo=True)
    c.run(f"potrace {temp_dir}/scaled-grayscale.pnm -s -a 3.0 -O 15 -G 12 --opttolerance 1.5 -o {output_svg}", echo=True)
    # This would marginally improve the size of the SVG
    # c.run(f"svgo {output_svg} --precision=1", echo=True)
    print(f"SVG created: {output_svg}")
    shutil.rmtree(temp_dir)


@task
def stl(c, output_dir=None, input_svg="pattern.svg", scad_file="cookie.scad", width=2.0):
    base_name = os.path.splitext(os.path.basename(input_svg))[0]
    if output_dir is None:
        output_dir = os.path.join(os.getcwd(), base_name)

    os.makedirs(output_dir, exist_ok=True)

    output_stl = os.path.join(output_dir, f"{base_name}.stl")
    output_info = os.path.join(output_dir, f"{base_name}.txt")
    common_scad = f'{OPENSCAD_PATH} --autocenter --viewall --imgsize=1920,1080 --backend=Manifold -D "width={int(width * 25.4)}" -D "svg_file=\\"{input_svg}\\""'
    c.run(
        f'{common_scad} --summary bounding-box -o {output_stl} {scad_file} 2>&1 | tee {output_info}'
    )

    output_png = os.path.join(output_dir, f"{base_name}.png")
    c.run(
        f'{common_scad}  -o {output_png} {scad_file}'
    )

    print(f"STL created: {output_stl} (PNG: {output_png})")
    c.run(f"cat {output_info} | grep Size")


@task
def svg_stl(c, output_dir=None, input_image="input.png", scad_file="cookie.scad", width=2.0):
    """
    Convert an input image to an SVG and then to an STL file.
    """
    base_name = os.path.splitext(os.path.basename(input_image))[0]
    output_svg = f"{base_name}.svg"

    svg(c, input_image=input_image)
    stl(c, output_dir=output_dir, input_svg=output_svg, scad_file=scad_file, width=width)

@task
def help(c):
    """Show usage information"""
    print("Usage:")
    print("  invoke svg-stl -i your-image.png")
    print("")
    print("Options:")
    print("  --input-image: Input PNG image (default: input.png)")
    print("  --output-svg: Output SVG file (default: pattern.svg)")

