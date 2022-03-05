#!/usr/bin/env ruby

# Generates a symmetrical dashed line for an SVG rounded square
require 'optparse'
require 'ostruct'

# Golden arguments: (so far)
# --scale 0.8 --width 150 --stroke-width 16 --radius 35 --spacing 0.5 --dashes 8 --output favicon.svg

class ArgParse
  def self.parse(args)
    options = OpenStruct.new
    opt_parser = OptionParser.new do |opts|
      opts.banner = "#{__FILE__}: [OPTIONS]"

      opts.separator ""
      opts.separator "Generates text for an SVG rounded square with symmetrical dashed line"
      opts.on("-r","--radius RADIUS", Float, "Rounded corner radius.") do |r|
        options.radius = r
      end
      opts.on("-s","--spacing SPACING", Float, "Space between dashes as a proportion of dash length") do |s|
        options.spacing = s
      end
      opts.on("-d","--dashes DASHES", Integer,"Number of dashes to squeeze on the square.") do |d|
        options.dashes = d
      end
      opts.on("-w","--width WIDTH", Float, "Width of square.") do |w|
        options.width = w
      end
      opts.on("--stroke-width WIDTH", Float, "Width of stroke.") do |w|
        options.stroke_width = w
      end
      opts.on("--scale SCALE", Float, "Scaling factor.") do |s|
        options.scale = s
      end
      opts.on('-o', '--output FILENAME', 'Output filename.') do |f|
        options.output = f
      end
      opts.on("-h","--help","Print this help.") do
        puts opts
        exit
      end
    end
    opt_parser.parse!(args)
    options
  end
end

def calculate_dashes(width, radius, num_dashes, spacing)
  diameter = radius * 2
  # side_len is the length of the straight part of a side
  side_len = width - diameter
  # Perimeter is equal to 4 sides + circumference of circle
  perimeter_len = side_len * 4 + Math::PI * diameter
  # Take the equations:
  # perimeter_len = dash_len * num_dashes + space_len * num_spaces
  # num_spaces = num_dashes
  # space_len = dash_len * spacing
  # ..solve for dash_len, and you get the following:
  dash_len = perimeter_len / (num_dashes * (spacing + 1))
  space_len = dash_len * spacing
  return dash_len, space_len, side_len
end

args = ArgParse.parse(ARGV)

dash_len, space_len, side_len = calculate_dashes(args.width, args.radius, args.dashes, args.spacing)

svg_template = (<<~SVG)
  <svg version="1.1"
     baseProfile="full"
     xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:ev="http://www.w3.org/2001/xml-events"
     viewBox="0 0 %{width} %{width}">
     <!-- background set in _config.yml <rect width="100%%" height="100%%" fill="#49483e" /> -->
     <rect width="%{width_percent}%%" height="%{width_percent}%%"
       x="%<rect_offset>.1fpx"
       y="%<rect_offset>.1fpx"
       rx="%{radius}px" ry="%{radius}px"
       fill="none" 
       stroke="#a6e22e" stroke-width="%{stroke_width}px"
       stroke-dashoffset="%<dash_offset>.1fpx"
       stroke-dasharray="%<dash_len>.1f %<space_len>.1f" />
</svg>
SVG

svg_output = svg_template % {
  # width is for view box which is the only thing left unscaled
  width: args.width,
  width_percent: args.scale * 100,
  rect_offset: args.width * (1.0 - args.scale) / 2,
  radius: args.radius * args.scale,
  stroke_width: args.stroke_width * args.scale,
  # In Safari / FF / Inkscape, dashes start at the end of the rounded corner in the top left, or in
  # other words the start of the straight part of the top side. In ImageMagick, dashes start at the
  # top of the top right rounded corner. No matter the renderer, they always proceed clockwise.
  # Even though stroke moves clockwise, a positive offset will move the stroke counter-clockwise.
  # Center the dash by moving it 1/2 the length of a dash relative to 1/2 the length of a side.
  # If the number of dashes is evenly divisible by 4, this will center a dash on each side.
  # Imagemagick: offset counter-clockwise by half of side length plus half of dash length.
  dash_offset: args.scale * (side_len / 2 + dash_len / 2),
  # Others: offset clockwise by half the side length minus half of dash length.
  # dash_offset: -1 * args.scale * (side_len / 2 - dash_len / 2),
  dash_len: dash_len * args.scale,
  space_len: space_len * args.scale,
}

if args.output then
  File.write(args.output, svg_output)
else
  puts svg_output
end
