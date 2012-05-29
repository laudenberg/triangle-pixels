triangle-pixels
===============

Inspired by [The pxl effect with javascript and canvas (and maths)](http://revdancatt.com/2012/03/31/the-pxl-effect-with-javascript-and-canvas-and-maths/), this script creates a similar "pxl"-effect for any input image with a couple of lines of Ruby.

### Installation

This script requires `rmagick` for reading the image and `haml` for writing svg.

    $ gem install rmagick
    $ gem install haml

Or, simply use the Gemfile in the root directory with bundler.

    $ bundle install
     
### Usage

    $ ./triangle-pixels /path/to/image.jpg 20 > /path/to/result.svg

Will load the file `/path/to/image.jpg` and produce `20` columns of squares (holding two triangles each). The number of rows is calculated according to the geometry of the image. The result is written to `/path/to/result.svg`.

