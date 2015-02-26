#!/usr/bin/env ruby

# Generates a symmetrical dashed line for an SVG rounded square
require 'optparse'
require 'ostruct'

# Golden parameters: (so far)
# width: 150
# radius: 35
# spacing: 0.4
# dashes: 16

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
      opts.on("-s","--spacing SPACING", Float, "Space between dashes as a percentage of dash width") do |s|
        options.spacing = s
      end
      opts.on("-d","--dashes DASHES", Integer,"Number of dashes to squeeze on the square.") do |d|
        options.dashes = d
      end
      opts.on("-w","--width WIDTH", Float, "Width of square.") do |w|
        options.width = w
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

def calculate_dashlen(width, radius, num_dashes, spacing)
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
  perimeter_len / (num_dashes * (spacing + 1))
end

args = ArgParse.parse(ARGV)

dash_len = calculate_dashlen(args.width, args.radius, args.dashes, args.spacing)
space_len = dash_len * args.spacing
# Offset so that a dash is centered on a side. If args.dashes is evenly
# divisible by 4, there will be a dash centered on each side.
dash_offset = ((args.width - args.radius * 2) / 2) - (dash_len / 2)
#for whatever reason, even though stroke moves clockwise, stroke-dashoffset
#will make the stroke start from a more counter-clockwise position!
svg_dash_offset = -1 * dash_offset

svg_template = %{
<!DOCTYPE html>
<html>
  <body>
    <h1>Missingtoken icon</h1>
    <div style="background-color:#49483e">
      <svg width="200" height="200">
        <rect x="10" y="10" rx="#{args.radius}" ry="#{args.radius}" width="#{args.width}" height="#{args.width}"
          style="fill:none;stroke:#a6e22e;stroke-width:10;stroke-dashoffset:#{svg_dash_offset};stroke-dasharray:#{dash_len},#{space_len}" />
      </svg>
    </div>
  </body>
</html>
}

puts svg_template
