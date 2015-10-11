require 'pry'
class Railway
  Town = Struct.new(:name, :neighbours, :distance)

  def initialize(map)
    @nodes = Hash.new{|h, name| h[name] = Town.new(name, [], Float::INFINITY)}
    @edges = {}

    map = validate_input!(map)

    map.each do |(origin, destination, distance)|
      @nodes[origin].neighbours << destination
      @nodes[destination].neighbours << origin

      @edges[[origin, destination]] = distance.to_i
    end
  end

  def to_s
    "towns: #{@nodes.keys.sort}\ntotal distance: #{@edges.values.reduce(:+)}"
  end

  def distance(*route)
    route.each_with_index.reduce(0) do |total, (town, i)|
      next total if i == route.length - 1
      total += @edges[[town, route[i+1]]]
    end
  rescue TypeError
    "NO SUCH ROUTE"
  end

  private
  def validate_input!(map)
    raise ArgumentError, "input should be enumerable" unless map.kind_of?(Enumerable)
    map = normalize_map(map)

    map.each do |section|
      raise ArgumentError, "invalid input format" if !section.is_a?(Enumerable) || section.length != 3
      raise ArgumentError, "distance must be numeric" unless (Integer(section.last) rescue false)
      raise ArgumentError, "distances can't be 0 or negative" if section.last.to_i <= 0
    end
  end

  def normalize_map(map)
    return map if map.any?{ |section| !section.is_a?(String) }
    map.collect do |section|
     [section.slice!(0), section.slice!(0), section]
    end
  end
end