# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Convert image to SVG: `ffmpeg -i input-image.png -vf "format=gray,erosion,lut='if(gt(val,150),0,255)',sobel,lut='if(gt(val,150),0,255)',scale=500:-1" scaled-grayscale.png && convert scaled-grayscale.png scaled-grayscale.pnm && potrace scaled-grayscale.pnm -s -o pattern.svg`
- Generate STL from OpenSCAD: `openscad -o pattern.stl pattern.scad`

## Code Style Guidelines
- Use 2-space indentation in OpenSCAD files
- Parameter variables should be declared at the top with descriptive comments
- Use descriptive variable names (e.g., step_height, scale_factor)
- Follow modular design with functions for reusable components
- Add comments explaining the purpose of code sections
- For SVG operations, use standard parameter order: scale, translate, resize
- When referencing files, always use relative paths
- Image files should be prepared as high-contrast silhouettes for best results

## Project Structure
- cookie.scad: Pottery stamp generator with configurable parameters
- Input files: PNG/SVG images for pattern creation
