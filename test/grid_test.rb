require "test/unit"
require "agwx_grids"

include AgwxGrids

DOY = 7
ROW = 1
COL = 5
VAL = -14.35 # The value for get_by_index(col,row,doy)

class TestAgwxGrid  < Test::Unit::TestCase
  def setup
    @test_data_path = File.join(File.dirname(__FILE__),'grids')
    @grid = Grid.new(File.join(@test_data_path,"WIMNTMin2002"),Grid::DAILY)
  end

  def test_can_load
    assert(@grid)
  end
  
  def test_each_value
    ii=0
    @grid.each_value(44.0,-89.0) {|val| assert_equal(Float, val.class); ii+=1}
    assert_equal(364, ii)
  end
  
  def test_get_by_index
    assert_equal(VAL, @grid.get_by_index(COL,ROW,DOY))
  end
  
  def test_layer
    assert_equal(GridLayer, @grid.layer(DOY).class)
  end
  
  def test_row
    assert_equal(Array, @grid.layer(DOY).row(1).class)
    assert_equal(VAL, @grid.layer(DOY).row(1)[5])
  end
  
  def test_y_latitude
    lat_start = @grid.mD.yStart
    lat_incr = @grid.mD.yIncr
    assert_in_delta(lat_start + 3 * lat_incr, @grid.latitude_for(3), 2 ** -20)
  end
  
  def test_x_longitude
    long_start = @grid.mD.xStart
    long_incr = @grid.mD.xIncr
    assert_in_delta(long_start + 3 * long_incr, @grid.longitude_for(3), 2 ** -20)
  end
  
  def test_each_with_doy
    layers = []
    doys = []
    @grid.each_with_doy do |layer,doy|
      layers << layer
      doys << doy
    end
    expected=(1..313).to_a + (315..365).to_a # DOY 314 is missing in the test grid
    doys.each_with_index { |actual,ii| assert_equal(expected[ii], actual, "ii: #{ii}, expected: #{expected[ii-5..ii+5].inspect}; actual: #{doys[ii-5..ii+5].inspect}\n#{@grid.layer_list.inspect}") }
  end
end
# begin # test the Grid class
#    puts "====== initializing a grid =========="
#    grid = Grid.new("grids/WIMNTMin2002",Grid::DAILY)
#    # puts "====== dumping each_value =========="
#    # grid.each_value(44.0,-89.0)  {|vapr| puts vapr}
#    for y_index in (0..grid.yDim)
#      puts grid.get_by_index(0,y_index,22)
#    end
# end