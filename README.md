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

    $ ./triangle-pixels.rb /path/to/image.jpg 20 50 > /path/to/result.svg

Will load the file `/path/to/image.jpg` to produce `20` columns of squares, holding two triangles, with a size of 50x50px each (defaults to 20px). The number of rows is calculated according to the geometry of the image. The result is written to `/path/to/result.svg`. You could use software like [Inkscape](http://www.inkscape.org/) to view, edit, or convert the image.

    $ inkscape -f /path/to/result.svg -e /path/to/result.png -C -d 90

Will convert the result to a PNG-image with a dpi of 90.

