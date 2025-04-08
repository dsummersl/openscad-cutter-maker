# Usage

To generate a pattern you must:

1. Convert an existing image to an SVG pattern.
2. Run openscad to generate the pattern.
3. Print!

## Convert an image to SVG

```sh
ffmpeg -i input-image.png -vf "format=gray,erosion,lut='if(gt(val,150),0,255)',sobel,lut='if(gt(val,150),0,255)',scale=500:-1" scaled-grayscale.png

convert scaled-grayscale.png scaled-grayscale.pnm  && potrace scaled-grayscale.pnm -s -o pattern.svg
```

## Generate the pattern

```sh
openscad -o pattern.stl pattern.scad
```
