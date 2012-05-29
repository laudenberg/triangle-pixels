#!/usr/bin/env ruby

# encoding: utf-8

require "rubygems"
require "RMagick"
require "haml"

include Magick

class Pixel

  def tile
    Tile.new(red, green, blue, 1.0)
  end

end

class Tile
  attr_accessor :red, :green, :blue, :norm

  def initialize(red = 0, green = 0, blue = 0, norm = 0.0)
    @red = red
    @green = green
    @blue = blue
    @norm = norm
  end

  def +(rhs)
    Tile.new(red + rhs.red, green + rhs.green, blue + rhs.blue, norm + rhs.norm)
  end

  def *(alpha)
    Tile.new(alpha * red, alpha * green, alpha * blue, alpha * norm)
  end

  def diff(rhs)
    # calculate the squared l2 norm of the difference
    rhs = rhs.normalized
    lhs = normalized
    (lhs.red + rhs.red) ** 2 + (lhs.green + rhs.green) ** 2 + (lhs.blue + rhs.blue) ** 2
  end

  def color
    throw "uargh" unless red == red
    throw "uargh" unless green == green
    throw "uargh" unless blue == blue
    scale = 256 * norm

    if scale > 0.0
      sprintf "#%02x%02x%02x", red / scale, green / scale, blue / scale
    else
      "#000000"
    end

  end

  def normalized
    if norm == 0.0
      self
    else
      Tile.new(red / norm, green / norm, blue / norm, 1.0)
    end
  end
    

  def to_s
    "#{red},#{green},#{blue} * #{norm}"
  end

end

class Float

  def sign
    s = self <=> 0.0
    if s == 0 then return 1 else return s end
  end

end

if ARGV.size < 1
  $stderr.puts "Usage: ./triangle-pixels.rb IMAGE_FILE NUMBER_OF_SQUARE_COLUMNS RESULTING_PIXELS_PER_SQUARE"
  $stderr.puts "       Resulting svg is written to stdout."
  $stderr.puts 
  exit -1
end  

image = ImageList.new(ARGV[0]).first
width = (ARGV[1] || 20).to_i
resulting_pixels_per_square = (ARGV[2] || 20).to_i
height = (width / (image.columns.to_f / image.rows)).to_i + 1
pixels_per_square = image.columns.to_f / width

$stderr.puts "Image: '#{image.filename}'"
$stderr.puts "Columns: #{width}"
$stderr.puts "Rows: #{height}"
$stderr.puts "Pixels per square: #{resulting_pixels_per_square}x#{resulting_pixels_per_square}"

buckets = Array.new(width + 1) {
  Array.new(height + 1) {
    {
      :left => Tile.new,
      :right => Tile.new,
      :top => Tile.new,
      :bottom => Tile.new
    }
  }
}

sections = {1 => {-1 => :top, 1 => :right}, -1 => {1 => :bottom, -1 => :left}}
image.each_pixel do |pixel, column, row|
  x = (column % pixels_per_square)
  y = (row % pixels_per_square)

  xalpha = [1, pixels_per_square - x].min
  yalpha = [1, pixels_per_square - y].min

  grid = [[column, xalpha], [column + 1, 1 - xalpha]].product [[row, yalpha], [row + 1, 1 - yalpha]]

  grid.each do |things|

    column = things[0][0]
    xalpha = things[0][1]
    row = things[1][0]
    yalpha = things[1][1]

    if xalpha == 0 || yalpha == 0
      next
    end

    bucket_col = (column / pixels_per_square).to_i
    bucket_row = (row / pixels_per_square).to_i

    # 0.0 <= x,y <= 1.0
    x = (column % pixels_per_square) / pixels_per_square
    y = (row % pixels_per_square) / pixels_per_square

    s = sections[(x - y).sign][(x + y - 1).sign]

    alpha = xalpha * yalpha
    buckets[bucket_col][bucket_row][s] += pixel.tile * alpha
  end

end

buckets.each do |array|

  array.each do |cell|
    a = (cell[:right].diff cell[:top]) + (cell[:left].diff cell[:bottom])
    b = (cell[:left].diff cell[:top]) + (cell[:right].diff cell[:bottom])

    if a < b
      cell[:right] = cell[:top] = (cell[:right].normalized + cell[:top].normalized)
      cell[:left] = cell[:bottom] = (cell[:left].normalized + cell[:bottom].normalized)
    else
      cell[:left] = cell[:top] = (cell[:left].normalized + cell[:top].normalized)
      cell[:right] = cell[:bottom] = (cell[:right].normalized + cell[:bottom].normalized)
    end

  end

end

engine = Haml::Engine.new(File.read("#{File.expand_path(File.dirname(__FILE__))}/triangle-pixels.haml"))
puts engine.render(Object.new, {:buckets => buckets, :scale => resulting_pixels_per_square})

