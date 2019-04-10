#!/usr/bin/env ruby

require_relative 'disease.rb'

# do not merge cluster that are less similar than this value
MERGE_THRESHOLD=0.9

class Cluster < Array
  def initialize(disease)
    super([disease])
  end

  def average_similarity(other)
    sum = 0.0
    count = 0
    self.each { |d1|
      other.each { |d2|
        tmp = d1.sorensen_dice(d2)
        sum += tmp
        count += 1
      }
    }
    sum / count
  end
end

diseases = {}
clusters = []

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
    end
  }
}

print "#{diseases.size} diseases\n"

# build cluster list by first merging diseases with
# similarity 1
clusters = []
diseases.values.each { |d|
  new_c = Cluster.new(d)
  c = clusters.find { |tmp| tmp.average_similarity(new_c) == 1.0 }
  if c
    c.concat(new_c)
  else
    clusters << new_c
  end
}
print "#{clusters.size} clusters\n"

diseases.values.map { |d| Cluster.new(d) }

# then perform hierarchical clustering
# keep a cache of the pairwise similarity values
$cache = Array.new(clusters.size) { Array.new(clusters.size) { nil } }

# function to find the pair of closest clusters
def find_closest(list)
  max_sim = 0.0
  best_pair = nil
  0.upto(list.size-2) { |i|
    (i+1).upto(list.size-1) { |j|
      d = if $cache[i][j].nil?
            $cache[i][j] = list[i].average_similarity(list[j])
          else
            $cache[i][j]
          end
      if d > max_sim && d > MERGE_THRESHOLD
        max_sim = d
        best_pair = [i, j]
      end
    }
  }

  if max_sim > MERGE_THRESHOLD
    print "merging #{best_pair.join('-')}, with similarity #{'%.2f' % (100*max_sim)}\n"
    $stdout.flush
    best_pair
  else
    nil
  end
end

i = 0
while (pair = find_closest(clusters)) && i < 1000
  a = pair.min
  b = pair.max
  # invalidate cache for a, and the values of other clusters towards a
  $cache[a].size.times { |j| $cache[a][j] = nil }
  clusters.size.times { |j| $cache[j][a] = nil }
  
  clusters[a].concat(clusters[b])
  clusters.delete_at(b)
  $cache.delete_at(b)
  
  i += 1
end

top = clusters.sort { |a, b| b.size <=> a.size }[0, 10]
top.each_with_index { |c, idx|
  print "Cluster #{idx}:\n"
  c.each { |disease|
    print "  #{disease}\n"
  }
}
