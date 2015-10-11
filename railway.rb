require 'pry'
class Railway
  Town = Struct.new(:name, :destinations)
  Route = Struct.new(:stops, :distance)

  TownDetails = Struct.new(:name, :destinations, :weight)

  def initialize(map)
    @towns = Hash.new{|h, name| h[name] = Town.new(name, [])}
    @connections = {}

    map = validate_input!(map)

    map.each do |(origin, destination, distance)|
      @towns[destination]
      @towns[origin].destinations << destination
      @connections[[origin, destination]] = distance.to_i
    end
    @cached_routes = Hash.new
  end

  def to_s
    "towns: #{@towns.keys.sort}\ntotal distance: #{@connections.values.reduce(:+)}"
  end

  def distance(*route)
    route.each_with_index.reduce(0) do |total, (town, i)|
      next total if i == route.length - 1
      total += @connections[[town, route[i+1]]]
    end
  rescue TypeError
    "NO SUCH ROUTE"
  end

  def routes_count(origin, target, condition=nil)
    count_routes_by_dijkstra(origin)

    @cached_routes[origin][target].count
  end

  def shortest_path(origin, target)
    count_routes_by_dijkstra(origin)

    @cached_routes[origin][target].min_by(&:distance).distance
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

  def count_routes_by_dijkstra(origin)
    return if @cached_routes[origin]

    routes = Hash.new([])
    towns = @towns.dup
    towns.each_pair do |name, town|
      towns[name] = TownDetails.new(town.name, town.destinations, town.name == origin ? 0 : Float::INFINITY)
    end

    until towns.empty?
      town = towns.values.min_by(&:weight)

      town.destinations.each do |target|
        distance = @connections[[town.name, target]]

        if town.name == origin
          route = Route.new(0, distance)
          routes[target] = [route]
        end

        routes[target] += routes[town.name].map do |incoming_route|
          Route.new(incoming_route.stops + 1, incoming_route.distance + distance)
        end
        towns[target].weight = routes[target].map(&:distance).min if towns.has_key?(target)
      end

      towns.delete(town.name)
    end

    @cached_routes[origin] = routes
  end
end