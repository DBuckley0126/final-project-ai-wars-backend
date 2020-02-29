require_relative './map_machine.rb'

module PathFinderMachine

  def self.convert_nodes_to_coordinate_strings(node_path)
    node_path.map do |node|
      node.coordinate_key
    end
  end

  def self.search(start_coordinate_string, end_coordinate_string, map_state)
    # Create copy of map_state with nodes
    node_map = PathFinderMachine.create_node_map(map_state)

    # Let's register a starting node and a ending node
    start_node = PathFinderMachine.get_node(node_map, start_coordinate_string)
    stop_node  = PathFinderMachine.get_node(node_map, end_coordinate_string)

    # There will be two sets at the center of the algorithm.
    # The first is the openset, that is the set that contains
    # all the nodes that we have not explored yet.
    # It is initialized with only the starting node.
    openset = [start_node]

    # The closed set is the second set that contains all
    # the nodes thar already been explored and are in our
    # path or are failing strategy
    closedset = []

    # Let's initialize the starting point
    # Obviously it has distance from start that is zero
    start_node.g = 0

    # and we evaluate the distance from the ending point
    start_node.h = start_node.distance(stop_node)

    # The search continues until there are nodes in the openset
    # If there are no nodes, the path will be an empty list.

    while openset.size > 0
      # The next node is the one that has the minimum distance
      # from the origin and the minimum distance from the exit.
      # Thus it should have the minimum value of f.
      min_node = PathFinderMachine.openset_min_f(openset)

      # If the next node selected is the stop node we are arrived.
      if min_node == stop_node
        # And we can return the path by reconstructing it 
        # recursively backward.
        node_path = PathFinderMachine.reconstruct_path(min_node)

        return PathFinderMachine.convert_nodes_to_coordinate_strings(node_path)
      end

      # We are now inspecting the min_node. We have to remove it
      # from the openset, and to add it to the closedset.
      openset -= [min_node]
      closedset += [min_node]

      # Let's test all the nodes that are near to the current one
      min_node.near(node_map).each do |near_node|
        # Obviously, we do not analyze the current node if it
        # is already in the closed set

        next if closedset.include?(near_node)

        # Let's make an evaluation of the distance from the 
        # starting point. We can evaluate the distance in a way
        # that we actually get a correct value of distance.
        # It must be saved in a temporary variable, because 
        # it must be checked against the g score inside the node
        # (if it was already evaluated)

        g_score = min_node.g + min_node.distance(near_node)

        # There are three conditions to be taken into account
        #  1. near_node is not in the openset. This is always an improvement
        #  2. near_node is in the openset, but the new g_score is lower
        #     so we have found a better strategy to reach near_node
        #  3. near_node has already a better g_score, or in any case
        #     this strategy is not an improvement

        # First case: the near_node point is a new node for the openset
        # thus it is an improvement

        if not openset.include?(near_node)
          openset += [near_node]
          improving = true

        # Second case: the near_node point was already in the openset 
        # but with a value of g that is lower with respect to the
        # one we have just found. That means that our current strategy
        # is reaching the point near_node faster. This means that we are 
        # improving.
        elsif g_score < near_node.g
          improving = true

        else
          improving = false
        end

        # We had an improvement
        if improving
          # so we reach y from x
          near_node.previous = min_node
          # we update the gscore value
          near_node.g = g_score
          # and we update also the value of the heuristic
          # distance from the stop_node
          near_node.h = near_node.distance(stop_node)
        end
      end

      # The loop instruction is over, thus we are ready to 
      # select a new node.
    end

    # If we never encountered a return before means that we 
    # have finished the node in the openset and we never
    # reached the stop point.
    # We are returning an empty path.
    return []
  end

  # Searches the node with the minimum f in the openset
  def self.openset_min_f(openset)
    return_node = openset[0]

    openset.each_with_index do |node, i|
      if return_node.f > openset[i].f
        return_node = openset[i]
      end
    end

    return return_node
  end

  def self.get_node(node_map, coordinate_string)
    node_map[coordinate_string][:node]
  end

  def self.create_node_map(map_state)
    output_node_map = {}

    map_state.each do |coordinate_key, value|
      output_node_map[coordinate_key] = {contents: value["contents"], node: Node.new(coordinate_key), effect: value["effect"]}
    end

    output_node_map
  end

  # It reconstructs the path by using a recursive function
  # that runs from the last node till the beginning.
  # It is stopped when the analyzed node has prev == nil
  def self.reconstruct_path(curr)
    return ( curr.previous ? PathFinderMachine.reconstruct_path(curr.previous) + [curr] : [] )
  end 
end