class Railway
  NO_ROUTE_MSG = "NO SUCH ROUTE"

  Town = Struct.new(:name, :destinations)
  Route = Struct.new(:stops, :distance)
  TownDetails = Struct.new(:name, :destinations, :weight)

  attr_accessor :cached_routes #TODO don't forget to delete me!
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

  def distance(*route)
    route.each_with_index.reduce(0) do |total, (town, i)|
      next total if i == route.length - 1
      total += @connections[[town, route[i+1]]]
    end
  rescue TypeError
    NO_ROUTE_MSG
  end

  def routes_count(origin, target, conditions)
    validate_conditions!(conditions)

    routes = if conditions[:stops]
      filter_routes_by_exact_stops(routes_for(origin)[target], conditions[:stops])
    elsif conditions[:max_stops]
      filter_routes_by_max_stops(routes_for(origin)[target], conditions[:max_stops])
    else
      routes_for(origin)[target]
    end
    filter_routes_by_max_distance(routes, conditions[:max_distance]).count
  end

  def shortest_path(origin, target)
    if routes_for(origin)[target].any?
      routes_for(origin)[target].min_by(&:distance).distance
    else
      NO_ROUTE_MSG
    end
  end

  def to_s
    "towns: #{@towns.keys.sort}\ntotal distance: #{@connections.values.reduce(:+)}"
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

  def validate_conditions!(conditions)
    acceptable_conditions = [:stops, :max_stops, :max_distance]
    raise ArgumentError, "conditions are missing" if conditions.empty?
    raise ArgumentError, "unacceptable condition" if (conditions.keys - acceptable_conditions).any?
    raise ArgumentError, "values should be positive numbers" if (conditions.values.any?{ |v| Integer(v) < 0 } rescue true)
    raise ArgumentError, "stops and max_stops cannot be used simultaneusly" if conditions.has_key?(:stops) && conditions.has_key?(:max_stops)
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

  def normalize_map(map)
    return map if map.any?{ |section| !section.is_a?(String) }
    map.collect do |section|
     [section.slice!(0), section.slice!(0), section]
    end
  end

  def routes_for(origin)
    count_routes_by_dijkstra(origin)
    @cached_routes[origin]
  end

  def filter_routes_by_exact_stops(routes, stops)
    routes.inject([]) do |filtered, route|
      filtered << route if route.stops == stops-1
      filtered
    end
  end

  def filter_routes_by_max_stops(routes, stops)
    routes.inject([]) do |filtered, route|
      filtered << route if route.stops < stops
      filtered
    end
  end

  def filter_routes_by_max_distance(routes, max_distance)
    return routes if max_distance.nil?
    total_distance = 0

    routes.inject([]) do |filtered, route|
      break filtered if (total_distance += route.distance) > max_distance
      filtered += [route]
    end
  end
end