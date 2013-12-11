  #    The Grid ADT maniputates a very simple ASCII format called a Grid File. Grid files
  #    are designed for data which is easily maintained as a 3D matrix. The following is 
  #    a typical top part of a Grid file:
  #  
  #  7 8 245      [XNo  YNo  ZNo]
  #   -93.000000 -87.000000  [XStart  XEnd]
  #   42.330002 47.000000  [YStart  YEnd]
  #   121 365 1      [ZStart  ZEnd  ZInc]
  #   -99.000000 0    [BadVal  #Decimal_Places]
  #   121      [ZIndex]
  #   8 10 7 4 4 4 4    [Grid Values]    
  #   7 6 6 4 5 4 4
  #   6 8 8 4 4 4 3
  #   7 8 9 6 4 3 3
  #   8 8 8 6 4 3 2
  #   8 8 6 4 4 2 1
  #   6 6 4 2 2 2 2
  #   4 4 2 2 0 2 2
  #   122
  #   19 21 18 14 14 14 13
module AgwxGrids
  class GridMetaData
    attr_writer :zDim
    attr_reader :xDim, :yDim, :zDim
    attr_reader :xStart, :xEnd, :xIncr
    attr_reader :yStart, :yEnd, :yIncr
    attr_writer :zStart, :zEnd, :zIncr
    attr_reader :zStart, :zEnd, :zIncr
    attr_writer :badVal
    attr_reader :badVal

    def xDim=(newXDim)
      @xDim = newXDim
      calcXIncr
    end
    def xStart=(newXStart)
      @xStart = newXStart
      calcXIncr
    end
    def xEnd=(newXEnd)
      @xEnd = newXEnd
      calcXIncr
    end

    def calcXIncr
      if @xStart != nil && @xEnd != nil && @xDim != nil then
        @xIncr = (@xEnd - @xStart) / (@xDim - 1)
      end
    end

    def yDim=(newYDim)
      @yDim = newYDim
      calcYIncr
    end

    def yStart=(newYStart)
      @yStart = newYStart
      calcYIncr
    end

    def yEnd=(newYEnd)
      @yEnd = newYEnd
      calcYIncr
    end

    def calcYIncr
      if @yStart != nil && @yEnd != nil && @yDim != nil then
        @yIncr = (@yEnd - @yStart) / (@yDim - 1)
      end
    end

    def to_s
      x = "xDim="+@xDim.to_s+",xStart="+@xStart.to_s+",xEnd="+@xEnd.to_s+",xIncr="+xIncr.to_s
      y = "yDim="+@yDim.to_s+",yStart="+@yStart.to_s+",yEnd="+@yEnd.to_s+",yIncr="+yIncr.to_s
      z = "zDim="+@zDim.to_s+",zStart="+@zStart.to_s+",zEnd="+@zEnd.to_s+",zIncr="+zIncr.to_s
      badVal = "badVal="+@badVal.to_s
      x+"\n"+y+"\n"+z+"\n"+badVal
    end

    def initialize(gridFile)
      readMeta(gridFile)
    end

    def readMeta(gridFile)
      @xDim,@yDim,@zDim = gridFile.gets.scan(/\d+/).collect { |s| s.to_f }
      @xStart,@xEnd = gridFile.gets.scan(/-*\d+.\d+/).collect {|s| s.to_f }
      calcXIncr
      @yStart,@yEnd = gridFile.gets.scan(/-*\d+.\d+/).collect {|s| s.to_f }
      calcYIncr
      @zStart,@zEnd,@zIncr = gridFile.gets.scan(/\d+/).collect {|s| s.to_i }
      @badVal = gridFile.gets.scan(/-*\d+.\d+/).collect {|s| s.to_f }
    end
  end

  class GridLayer
    attr_writer :zIndex
    attr_reader :zIndex
    attr_reader :rows
    def initialize(gridFile,metaData)
      @zIndex = gridFile.gets.scan(/\d+/)[0].to_i
      @rows = Array.new
      for row in 0...metaData.yDim
        @rows[row] = gridFile.gets.scan(/-*\d+.\d+/).collect {|s| s.to_f }
      end
    end
    def to_s
      row0 = @rows[0]
      row0Length = row0.length
      "zIndex: #{@zIndex} num rows: #{@rows.length} num cols: #{row0Length}\n row 0: #{@rows[0]}"
    end
    # return value for x-y posn (x and y in tuple space, not "real" space)
    def get(x,y)
      row = @rows[y]
      if row == nil
          nil
      else
        # puts "GLayer.get got a row: #{row.inspect} and the value is #{row[x]}"
        row[x]
      end
    end
    # compare two layers (based on zIndex)
    def <=>(aLayer)
      if @zIndex < aLayer.zIndex then
          return -1
      elsif @zIndex == aLayer.zIndex then
          return 0
      else
          return 1
      end
    end
  
    def row(y)
      @rows[y]
    end
  
  end


  class Grid
    include Enumerable
    HOURLY=0
    DAILY=1
    attr_reader :period, :xDim, :yDim, :mD

    def initialize(path,period)
      @layers = {}
      File.open(path) do |gridFile|
        @mD = GridMetaData.new(gridFile)
        if @mD == nil
          raise "nil metadata"
        end
        @xDim = @mD.xDim
        @yDim = @mD.yDim
        @mD.zStart.step(@mD.zEnd,@mD.zIncr) do |layer_index|
          if (!(gridFile.eof) && (layer = GridLayer.new(gridFile,@mD)))
            @layers[layer.zIndex] = layer
          end
        end
      end
    end
  
    # Find the nearest index to the given coord (params in real space, return is a zero-based index)
    def self.nearest(coord,start,incr)
      # convert coord to a lower-bound index (i.e. truncating integer conversion)
      trunc = ((coord - start)/incr).to_i
      # Does "trunc" the index of the closest real-space coord, or the next one up?
      coord - (start + incr*trunc) > incr / 2.0 ? trunc + 1 : trunc
    end
    
    # Convert coordinates in real XY space to indices. Note that Z is sort-of a real-space coord, but
    # represents a quantized there-or-not value like a DOY, not a scalar.
    def realToIndex(x,y,z) 
      @my_ii = self.nearest(x,@mD.xStart,@mD.xIncr)
      @my_jj = self.nearest(y,@mD.yStart,@mD.yIncr)
      @my_doy = z
      # puts "realToIndex: x #{x}, xStart #{@mD.xStart}, xIncr #{@mD.xIncr} myX #{@my_ii}; y #{y}, myY #{@my_jj} z #{z}, myZ #{@my_doy}"
      [@my_ii,@my_jj,@my_doy]
    end
  
    def get(x,y,z)
      # puts "get #{x},#{y},#{z}"
      # puts "xStart=#{@mD.xStart}, yStart=#{@mD.yStart}, zStart=#{@mD.zStart}"
      realToIndex(x,y,z)
      # puts "@my_ii=#{@my_ii}, @my_jj=#{@my_jj}, @my_doy=#{@my_doy}"
      # puts "#{@layers[@my_doy]}"
      if @layers[@my_doy] == nil
          nil
      else
          val = @layers[@my_doy].get(@my_ii,@my_jj)
          val == mD.badVal ? nil : val
      end
    end

    # Grids are stored from low to high latitude, so as you look at the text file, it's mirrored vertically.
    # The first line in a given grid layer is the LOWEST latitude, the last is the highest.
    def get_by_index(longitude_index,latitude_index,doy)
      if @layers[doy]
        val = @layers[doy].get(longitude_index,latitude_index)
        val == mD.badVal ? nil : val
      else
        nil
      end
    end

    def each_value(lat,long)
      # note switch here -- grids do longitude as X
      realToIndex(long,lat,0)
      @layers.keys.sort.each do |doy|
        layer = @layers[doy]
        if layer == nil
            yield nil
        else
          val = layer.get(@my_ii,@my_jj)
          val = nil if val == mD.badVal
          yield val
        end
      end 
    end
  
    def each
      @layers.each { |layer| yield layer }
    end
    
    def each_with_doy
      @layers.keys.sort.each {|doy| yield [layer(doy),doy]}
    end
    
    def at_by_index(longitude_index,latitude_index)
      @layers.inject({}) do |hash,arr|
        doy = arr[0]
        layer = arr[1]
        hash.merge doy => layer.get(longitude_index,latitude_index)
      end
    end
    
    def at_by_long_lat(long,lat)
      @layers.keys.inject({}) do |hash,doy|
        hash.merge doy => get(long,lat,doy)
      end
    end
  
    def layer_list
      @layers.keys
    end
  
    def layer(doy)
      @layers[doy]
    end
    
    def latitude_for(index)
      mD.yStart + (index * mD.yIncr)
    end
  
    def longitude_for(index)
      mD.xStart + (index * mD.xIncr)
    end
  end
end