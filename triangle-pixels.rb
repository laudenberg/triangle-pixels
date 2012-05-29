#!/usr/bin/env ruby

# encoding: utf-8

require "RMagick"
include Magick
require "haml"

class Tile
    attr_accessor :red, :green, :blue, :norm

    def initialize(red = 0, green = 0, blue = 0, norm = 0.0)
      @red = red
      @green = green
      @blue = blue
      @norm = norm
    end

    def *(alpha)
        Tile.new(red * alpha, green * alpha, blue * alpha, norm)
    end

    def /(alpha)
        Tile.new(red / alpha, green / alpha, blue / alpha, norm)
    end

    def +(rhs)
        Tile.new(red + rhs.red, green + rhs.green, blue + rhs.blue, norm + rhs.norm)
    end

    def -(rhs)
        Tile.new(red - rhs.red, green - rhs.green, blue - rhs.blue, norm - rhs.norm)
    end

    def <(rhs)
        square_length < rhs.square_length
    end

    def square_length
        red * red + green * green + blue * blue
    end

    def abs
        Tile.new(red.abs, green.abs, blue.abs, norm)
    end

    def color
        scale = 256 * norm

        if scale > 0.0
          sprintf "#%02x%02x%02x", red / scale, green / scale, blue / scale
        else
          "#000000"
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


image = ImageList.new(ARGV[0]).first
width = ARGV[1].to_i
height = (width / (image.columns.to_f / image.rows)).to_i + 1
pixels_per_square = image.columns.to_f / width

buckets = Array.new(width + 1) {
    Array.new(height + 1) {
                {left: Tile.new,
                right: Tile.new,
                top: Tile.new,
                bottom: Tile.new}
    }
}

image.each_pixel do |pixel, column, row|
    x = (column % pixels_per_square)
    y = (row % pixels_per_square)

    xalpha = [1, pixels_per_square - x].min
    yalpha = [1, pixels_per_square - y].min

    grid = [[column, xalpha], [column+1, 1-xalpha]].product [[row, yalpha], [row+1, 1-yalpha]]

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
        x = (column % pixels_per_square) / pixels_per_square
        y = (row % pixels_per_square) / pixels_per_square
        # now 0.0 <= x,y <= 1.0

        # \
        #  \ x - y < 0
        #   \

        #   /
        #  / x + y > 1 or x + y - 1 > 0
        # /
        sections = {-1 => {-1 => :top, 1 => :right}, 1 => {1 => :bottom, -1 => :left}}
        s = sections[(x - y).sign][(x + y - 1).sign]

        buckets[bucket_col][bucket_row][s] += Tile.new(pixel.red, pixel.green, pixel.blue, xalpha * yalpha)

    end

end

buckets.each do |array|
    array.each do |cell|
        a = (cell[:right] - cell[:top]).abs + (cell[:left] - cell[:bottom]).abs
        b = (cell[:left] - cell[:top]).abs + (cell[:right] - cell[:bottom]).abs
        if a < b
            cell[:right] = cell[:top] = (cell[:right] + cell[:top]) / 2
            cell[:left] = cell[:bottom] = (cell[:left] + cell[:bottom]) / 2
        else
            cell[:left] = cell[:top] = (cell[:left] + cell[:top]) / 2
            cell[:right] = cell[:bottom] = (cell[:right] + cell[:bottom]) / 2
        end
    end
end

engine = Haml::Engine.new(File.read("triangle-pixels.haml"))
puts engine.render(Object.new, {buckets: buckets, scale: 20})

