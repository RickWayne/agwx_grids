# AgwxGrids

This gem implements the simple three-dimensional grid datatype beloved at Soil Science since the Larry Murdoch days of 1997.

Example of a grid file (also on Andi). This one defines a 7 x 8 cell grid, currently containing 245 layers starting at 121 and ending at 365. Note that the Z layers are not necessarily contiguous; there can be layers missing from the file (e.g. if layer 125 were missing, the first few lines here would be the same except the number of layers would be 244 instead of 245). The file format is happy with that, and implementations should be too (that's why each layer of grid values has an index). The stuff in square brackets are illustrative, they would not appear in actual files (there's no provision for embedded comments).

Also note that the rows of the raster are stored in reverse order from what you'd see on a map! So the row beginning "8 10 7..." below
corresponds to the SMALLEST latitude (43.330002)!

(From Larry's original dox) The following is a typical top part of a Grid file. Note the space at the start of each line. This allows you to examine the Z index list with something like: egrep '^ [0-9]+$' grid_file_name

  7 8 245                   [XNo  YNo  ZNo]
  -93.000000 -87.000000     [XStart  XEnd]
  42.330002 47.000000       [YStart  YEnd]
  121 365 1                 [ZStart  ZEnd  ZInc]
  -99.000000 0              [BadVal  #Decimal_Places]
  121                       [ZIndex]
  8 10 7 4 4 4 4            [Grid Values]
  7 6 6 4 5 4 4
  6 8 8 4 4 4 3
  7 8 9 6 4 3 3
  8 8 8 6 4 3 2
  8 8 6 4 4 2 1
  6 6 4 2 2 2 2
  4 4 2 2 0 2 2
  122
  19 21 18 14 14 14 13

Not much to say outside of the rdoc for the API of the gem.

## Installation

Add this line to your application's Gemfile:

    gem 'agwx_grids'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install agwx_grids

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
