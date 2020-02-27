# The Node also contains 
#  - @x, @y: indication of the position of the node
#  - @previous: the edge to previous position
#  - @near: the edges to next positions
#  - @h: the heuristic distance to the stop node
#  - @g: the heuristic distance to the start node
#  - @f: The total heuristic distance is the sum of (@g + @h)

class Node

  attr_reader :x, :y, :coordinate_key
  attr_accessor :g, :h, :previous

  def initialize(coordinate_key)
    @x = coordinate_key.slice(0,2).to_i
    @y = coordinate_key.slice(2, 2).to_i
    @coordinate_key = coordinate_key
    @g = 0.0
    @h = 0.0
  end

  # Total heuristic distance
  def f
    @g + @h
  end

  # Evaluates the distance of the current node with another 
  def distance(node)
    return (
      (@x - node.x) ** 2 +
      (@y - node.y) ** 2
    ) ** (0.5)
  end

  def reset
    @g = 0.0
    @h = 0.0
    @prev = nil
  end
  
  # Gets potential neighbors, checks map for contents
  def near(node_map)
    output_nodes = []
    
    potential_neighbor_strings().each do |coordinate_string|

      if !node_map[coordinate_string][:contents]
        output_nodes << node_map[coordinate_string][:node]
      end
    end

    output_nodes
  end



  # Outputs array of string coordinates which are all possible nodes next to self
  def potential_neighbor_strings

    north_node_x = @x
    north_node_y = @y + 1

    east_node_x = @x + 1
    east_node_y = @y

    south_node_x = @x
    south_node_y = @y - 1

    west_node_x = @x - 1
    west_node_y = @y   

    check_potential_neighbor_nodes_validity([{x: west_node_x, y: west_node_y}, {x: north_node_x, y: north_node_y}, {x: east_node_x, y: east_node_y}, {x: south_node_x, y: south_node_y}])
  end

  private
  # If potential node string is a valid coordinate on map, add to output array
  def check_potential_neighbor_nodes_validity(array_of_potential_neighbor_nodes)
    max_x = 50
    max_y = 50

    output_array = []

    array_of_potential_neighbor_nodes.each do |node|
      if node[:x] > 0 && node[:x] < max_x+1 && node[:y] > 0 && node[:y] < max_y+1
        string_x = node[:x].to_s
        string_y = node[:y].to_s
      
        if string_x.length <= 1
          string_x = "0" + string_x
        end
      
        if string_y.length <= 1
          string_y = "0" + string_y
        end
      
        output_array.push("#{string_x}#{string_y}")
      end  
    end

    output_array
  end

end