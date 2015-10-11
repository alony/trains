class Railway
  Town = Struct.new(:name, :neighbours, :distance)

  def initialize(map)
    @nodes = Hash.new{|h, name| h[name] = Town.new(name, [], Float::INFINITY)}
    @edges = {}

    map = normalize_map(map)
    validate_input!(map)

    map.each do |(origin, destination, distance)|
      @nodes[origin].neighbours << destination
      @nodes[destination].neighbours << origin

      @edges[[origin, destination]] = distance
    end
  end

  private
  def validate_input!(map)
    raise ArgumentError, "input should be enumerable" unless map.kind_of?(Enumerable)
  end

  def normalize_map(map)
    return map if map.any?{ |section| !section.is_a?(String) }
    map.collect do |section|
     [section.slice!(0), section.slice!(0), section.to_i]
    end
  end
end