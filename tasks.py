from invoke import task
import os
import shutil


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
    c.run(
        f"ffmpeg -i {input_image} -vf \"format=gray,boxblur=10:1,erosion,lut='if(gt(val,150),0,255)',sobel,lut='if(gt(val,150),0,255)',scale=500:-1\" {temp_dir}/scaled-grayscale.png"
    )
    c.run(f"convert {temp_dir}/scaled-grayscale.png {temp_dir}/scaled-grayscale.pnm")
    c.run(f"potrace {temp_dir}/scaled-grayscale.pnm -s -a 2 -O 1 -G 1 -o {output_svg}")
    print(f"SVG created: {output_svg}")
    shutil.rmtree(temp_dir)


@task
def stl(c, input_svg="pattern.svg", scad_file="cookie.scad"):
    base_name = os.path.splitext(os.path.basename(input_svg))[0]
    output_dir = os.path.join(os.getcwd(), base_name)
    os.makedirs(output_dir, exist_ok=True)

    output_stl = os.path.join(output_dir, f"{base_name}.stl")
    output_info = os.path.join(output_dir, f"{base_name}.txt")
    c.run(
        f'/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD --summary bounding-box --backend=Manifold -D "svg_file=\\"{input_svg}\\"" -o {output_stl} {scad_file} 2>&1 | tee {output_info}'
    )

    output_png = os.path.join(output_dir, f"{base_name}.png")
    c.run(
        f'/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD --autocenter --viewall --imgsize=1920,1080 -D "svg_file=\\"{input_svg}\\"" -o {output_png} {scad_file}'
    )

    print(f"STL created: {output_stl} (PNG: {output_png})")
    c.run(f"cat {output_info} | grep Size")


@task
def help(c):
    """Show usage information"""
    print("Usage:")
    print("  invoke build -i your-image.png -o our-model.stl")
    print("")
    print("Options:")
    print("  --input-image: Input PNG image (default: input.png)")
    print("  --output-svg: Output SVG file (default: pattern.svg)")

