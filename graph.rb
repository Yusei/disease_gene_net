class Graph
  class Node
    attr_reader :name
    
    def initialize(str)
      @name = str
      @edges = {}
    end

    def add_edge(dest)
      @edges[dest] = true
    end

    def connected_to?(dest)
      @edges[dest] != nil
    end

    def degree
      @edges.size
    end
  end

  attr_reader :edges
  
  def initialize
    @nodes = {}
    @edges = []
  end

  def nodes
    @nodes.values
  end

  def node(str)
    @nodes[str]
  end

  def new_node(str)
    @nodes[str] = Node.new(str)
  end

  def add_edge(node1, node2)
    @nodes[node1].add_edge(node2)
    @nodes[node2].add_edge(node1)
    @edges << [node1, node2]
  end
end
