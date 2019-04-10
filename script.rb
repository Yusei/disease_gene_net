#!/usr/bin/env ruby

require_relative 'graph.rb'
require_relative 'disease.rb'

diseases = {}
genes = {}

File.open('Disease-Gene-Net.txt') { |file|
  file.readline # skip header line
  file.each_line { |line|
    if line =~ /^([\w\d]+)\s+(.+)/
      gene = $1
      disease = $2

      # initialize gene list with [] if needed
      diseases[disease] ||= Disease.new(disease)
      # and append this gene to the list
      diseases[disease] << gene
      
      genes[gene] ||= []
      genes[gene] << disease
    end
  }
}

print "#{diseases.size} diseases\n"
print "#{genes.size} genes\n"

# create a graph with nodes for each gene
gene_graph = Graph.new
genes.keys.each { |name| gene_graph.new_node(name) }
# add edges between nodes if the genes share a disease
diseases.each { |name, gene_list|
  gene_list.each { |gene1|
    gene_list.each { |gene2|
      next if gene1 == gene2
      gene_graph.add_edge(gene1, gene2)
    }
  }
}

# output genes by descending order of connectivity
n = 10
print "The #{n} more central genes are:\n"
list = gene_graph.nodes.sort { |a, b| b.degree <=> a.degree }
list[0, n].each { |node|
  print "#{node.name}: connected to #{node.degree} diseases\n"
}
print "\n"

# we don't need a hash anymore, just an array
diseases = diseases.values
all = []
# compute pairwise similarities
0.upto(diseases.size-2) { |i|
  (i+1).upto(diseases.size-1) { |j|
    similarity = diseases[i].sorensen_dice(diseases[j])
    all << [similarity, i, j]
  }
}
# sort by descending order
all.sort! { |a,b| b.first <=> a.first }
# output the 10 best ones
10.times { |k|
  similarity, i, j = all[k]
  print "#{diseases[i]} and #{diseases[j]} have a similarity of #{similarity}\n"
}
