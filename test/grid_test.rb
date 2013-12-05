require "test/unit"
require "agwx_grids"

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