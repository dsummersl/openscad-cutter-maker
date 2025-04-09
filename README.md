# Usage

To generate a pattern you must:

1. Convert an existing image to an SVG pattern.
2. Run openscad to generate the pattern.
3. Print!

```sh
poetry install
invoke svg -i zinnia.png
invoke stl -i zinnia.svg
```
