# An example of how to produce a box-and-whisker plots with Rubyvis
# From http://www.hpa-bioinformatics.org.uk/biosnippets/snippets/102.txt

### IMPORTS

require 'rubyvis'


### CONSTANTS & DEFINES

# the example data to be plotted in the form [[name, data-arr], ...]
DATA = [
   ['Row A', [4.3, 5.1, 3.9, 4.5, 4.4, 4.9, 5.0, 4.7, 4.1, 4.6, 4.4, 4.3, 4.2]],
   ['Row B', [4.2, 5.9, 3.0, 4.4, 5.9, 4.6, 4.0, 4.5, 4.3, 4.2, 4.1, 4.4, 4.3]],
   ['Row C', [4.9, 4.6, 4.0, 4.5, 5.2, 4.9, 4.3, 4.8, 4.3, 4.2, 5.1, 3.4, 4.3]], 
]


### IMPLEMENTATION ###

# Renders data as a box-and-whisker plot
#
# The object is instantiated with style details for the plot and can be used
# (via render) to draw several different plots.
#
class WhiskerPlotter
   
   attr_accessor(
      :data_quartiles,  # [[name, q0, q1, q2, q3, q4], ...]
      :plot_wt,
      :plot_ht,
      :canvas_wt,
      :canvas_ht,
      :margin,
      :title,
      :bar_clr,
      :whisker_clr
   )
   
   def initialize(kwargs={})
      ## Preconditions:
      opts = OpenStruct.new({
         :plot_ht => 500,
         :plot_wt => 800,
         :margin => 0,
         :title => nil,
         :bar_clr => "blue",
         :whisker_clr => "blue"        
      }.merge(kwargs))
      ## Main:
      @plot_ht = opts.plot_ht
      @plot_wt = opts.plot_wt
      @margin = opts.margin
      @canvas_ht = opts.plot_ht + (2 * @margin)
      @canvas_wt = opts.plot_wt + (2 * @margin)
      @title = opts.title
      @bar_clr = opts.bar_clr
      @whisker_clr = opts.whisker_clr
   end
   
   # Create a plot of the passed data and return as an SVG.
   #
   # @param [] data   an array of pairs, being [name, [data]]
   #
   def render_data(data)
      # calculate quartiles for plot, use this as data
      @data_quartiles = DATA.collect { |row|
         data = quartiles(row[1])
         OpenStruct.new(
            :name => row[0],
            :q0 => data[0],
            :q1 => data[1],
            :q2 => data[2],
            :q3 => data[3],
            :q4 => data[4],
            :index => 0
         )                                      
      }
      # NOTE: need index to lay out coloumns horizontally
      @data_quartiles.each_with_index { |d, i|
         d.index = i
      }
      # find limits of data so we know where axes are
      data_min = @data_quartiles.collect { |col| col.q0 }.min()
      data_max = @data_quartiles.collect { |col| col.q4 }.max()
      bounds = bounds([data_min, data_max])
      plot_range = bounds[1] - bounds[0]

      
      # make area for plotting
      # left, etc. set padding so actual size is ht/wt + padding
      vis = pv.Panel.new()
         .width(@canvas_wt)
         .height(@canvas_ht)
         .margin(@margin)
         .left(30)
         .bottom(20)
         .top(10)
         .right(10)
         
      # adhoc guess at bar width
      bar_width = @plot_wt / @data_quartiles.size() * 0.8
      
      # scaling to position datapoints in plot
      vert = pv.Scale.linear(bounds[0], bounds[1]).range(0, @plot_ht)
      horiz = pv.Scale.linear(0, @data_quartiles.size()).range(0, @plot_wt)

      # where to draw labels on graph
      label_ticks = vert.ticks.each_slice(4).map(&:first)

      # make horizontal lines:
      # - what values are drawn
      # - where the bottom of it appears
      # - what color to make the line
      # - the width of the line
      # - antialias it?
      # - add a label
      #   - where does label appear relative to line
      #   - how is the text aligned in own space
      #   - align text vertically ("top" looks like "middle")
      #   - what appears in the label
      vis.add(pv.Rule)
         .data(vert.ticks())  
         .bottom(lambda {|d| vert.scale(d)})                             
         .strokeStyle(lambda { |d| label_ticks.member?(d) ?  "black" : "lightblue" })
         .line_width(lambda { |d| label_ticks.member?(d) ?  0.5 : 0.1 })
         .antialias(true)
         .add(pv.Label)                                      
            .left(0)                                           
            .textAlign("right")
            .textBaseline("top")
            .text(lambda {|d| label_ticks.member?(d) ?  sprintf("%0.2f", d) : '' })             
      
      # y (vertical) axis
      vis.add(pv.Rule)
         .data([0])
         .left(horiz.scale(0))
         .bottom(@margin)
         .strokeStyle("black")
         
      # make the main body of boxplot
      vis.add(pv.Rule)
         .data(@data_quartiles)
         .left(lambda {|d| horiz.scale(d.index + 0.5) })
         .bottom(lambda {|d| vert.scale(d.q1)})
         .lineWidth(bar_width)
         .height(lambda {|d| vert.scale(d.q3) - vert.scale(d.q1)})
         .strokeStyle(@bar_clr)

      # add bottom labels
      vis.add(pv.Label)
         .data(@data_quartiles)
         .left(lambda {|d| horiz.scale(d.index + 0.5) })
         .bottom(0)
         .text_baseline("top")
         .text_margin(15)
         .textAlign("center")
         .text(lambda {|d| d.name })

      # make the whisker      
      vis.add(pv.Rule)
         .data(@data_quartiles)
         .left(lambda {|d| horiz.scale(d.index + 0.5)})
         .bottom(lambda {|d| vert.scale(d.q0)})
         .lineWidth(1)
         .height(lambda {|d| vert.scale(d.q4) - vert.scale(d.q0)})
         .strokeStyle(@bar_clr)

      # make the median line     
      vis.add(pv.Rule)
         .data(@data_quartiles)
         .left(lambda {|d| horiz.scale(d.index + 0.5)})
         .bottom(lambda {|d| vert.scale(d.q2)})
         .height(1)
         .lineWidth(bar_width)
         .strokeStyle("white")
      
      vis.render()
      return vis.to_svg()
   end

   # Takes a numeric array and returns the min, q1, q2 (median), q3, max.
   #
   # @param [Array]  arr  a list or array
   #
   # There's a number of ways of calculating percentiles (and thus quartiles),
   # especially when it comes to interpolating between points. This uses the
   # simplest continuous method, doing a weighted sum of neighbouring values.
   #
   def quartiles(arr)
      sort_arr = arr.sort()
      len = sort_arr.size()
      q1_q2_q3 = [0.25, 0.5, 0.75].collect { |v|
         indx_f = (len * v) - 0.5
         indx_i = indx_f.to_i()
         if (indx_i == indx_f)
            sort_arr[indx_i]
         else
            res = indx_f - indx_i
            (sort_arr[indx_i] * (1 - res)) + (sort_arr[indx_i+1] * res)
         end
      }
      return [sort_arr[0]] + q1_q2_q3 + [sort_arr[-1]] 
   end
   
   # Return neat bounds for graphing purposes
   #
   # @param [Array] arr   figures to fall within bounds.
   #
   # @returns min, max, unit
   #
   # For graphing purposes, we need to know how much "space" to put around
   # the depicted figures. That is, if we are graphing values of 61, 62 and 64, it
   # is wasteful to graph 0 to 100. Graphing from 61 to 64 strictly is cramped.
   # This function assesses the range of the data and returns bounds based on that,
   # that put some distance around the data.
   #
   # @example
   #    bounds([7,5,2,0])      # => [-1.0, 8.0, 1.0]
   #    bounds([20.5, 21.2])   # => [20.4, 21.3, 0.1]
   #
   def bounds(arr)
      min, max = arr.min(), arr.max()
      range = max - min
      # how many figures in the range
      range_digits = Math.log10(range).ceil()
      range_scale = 10.0**(range_digits-1)
      min_bound = ((min / range_scale) - 1) * range_scale
      max_bound = ((max / range_scale) + 1) * range_scale
      return min_bound, max_bound, range_scale
   end   
   
end


### TEST & DEMO CODE

pltr = WhiskerPlotter.new()
svg = pltr.render_data(DATA)
outfile = open('rv-out.svg', 'w')
outfile.write (svg)
outfile.close()


### END ###

