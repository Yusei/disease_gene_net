# Basically just an array of genes, but with
# a name field and a similarity function
class Disease < Array
  attr_reader :name
  def initialize(name, gene_list = [])
    super(gene_list)
    @name = name
  end

  # set similarity measure
  def sorensen_dice(other)
    intersect = self & other
    similarity = 2 * intersect.size.to_f / (self.size + other.size)
  end

  def to_s
    @name
  end
end
