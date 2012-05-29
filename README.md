triangle-pixels
===============

Inspired by [The pxl effect with javascript and canvas (and maths)](http://revdancatt.com/2012/03/31/the-pxl-effect-with-javascript-and-canvas-and-maths/), this script creates a similar "pxl"-effect for any input image with a couple of lines of Ruby.

### Installation

This script requires requires `rmagick` for reading the image and `haml` for writing svg.

    gem install rmagick
    gem install haml

### Usage

    $ ./triangle-pixels /path/to/image.jpg 20 > /path/to/result.svg

Will load the file `/path/to/image.jpg` and uses `20` squares in widths to create 40 triangles. Height is calculated according to the geometry of the image. The result is then written into `/path/to/result.svg`.

