require './railway'

describe 'Railway' do
  let(:railway) { Railway.new %w[AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7] }

  describe "initialization" do
    it "should create a map" do
      expect(Railway.new([[:A, :B, 5], [:B, :C, 7], [:D, :E, 10]]).to_s).to eq "towns: [:A, :B, :C, :D, :E]\ntotal distance: 22"
    end

    it "should accept only a collection" do
      expect(->{ Railway.new "AB5" }).to raise_exception(ArgumentError, "input should be enumerable")
    end

    it "should not accept negative distances" do
      expect(->{ Railway.new [[:A, :B, 5], [:B, :C, -7]] }).to raise_exception(ArgumentError, "distances can't be 0 or negative")
    end

    it "should not accept any other input, except 3-elements array" do
      validation_message = "invalid input format"
      expect(->{ Railway.new [[:A, :B]] }).to raise_exception(ArgumentError, validation_message)
      expect(->{ Railway.new [:A] }).to raise_exception(ArgumentError, validation_message)
      expect(->{ Railway.new({:A => :B}) }).to raise_exception(ArgumentError, validation_message)
      expect(->{ Railway.new [[:A, :B, 3, 8]] }).to raise_exception(ArgumentError, validation_message)
    end

    describe "simplified form" do
      it "should accept input in simplified form" do
        expect(Railway.new(["AB5", "BC7", "DE20"]).to_s).to eq "towns: [\"A\", \"B\", \"C\", \"D\", \"E\"]\ntotal distance: 32"
      end

      it "should validate distances" do
        expect(->{ Railway.new ["AB#", "BCD"] }).to raise_exception(ArgumentError, "distance must be numeric")
      end

      it "should not accept negative distances" do
        expect(->{ Railway.new ["AB-5", "CD8"] }).to raise_exception(ArgumentError, "distances can't be 0 or negative")
      end
    end
  end

  describe "#to_s" do
    it "should contain a list of towns" do
      expect(Railway.new(["AB5", "BC7"]).to_s).to include "\"A\", \"B\", \"C\""
    end

    it "should count total distance" do
      expect(Railway.new(["AB5", "BC7"]).to_s).to include "total distance: 12"
    end
  end

  describe "#distance" do
    it "should calculate distance between towns" do
      expect(railway.distance "A", "B", "C").to eq 9
      expect(railway.distance "A", "D").to eq 5
      expect(railway.distance "A", "D", "C").to eq 13
      expect(railway.distance "A", "E", "B", "C", "D").to eq 22
    end

    it "should warn if there is no such direct connection" do
      expect(railway.distance "A", "E", "D").to eq "NO SUCH ROUTE"
    end
  end

  describe "#routes_count" do
    it "should count routes with stops limit" do
      expect(railway.routes_count("C", "C", max_stops: 3)).to eq 2
    end

    it "should count routes with exact stops number" do
      expect(railway.routes_count("A", "C", stops: 2)).to eq 2
    end

    it "should count routes with distance limit" do
      expect(railway.routes_count("C", "C", max_distance: 30)).to eq 2
    end

    it "should accept only :stops, :max_stops and :distance keys" do
      expect(->{ railway.routes_count("C", "C", stops: 5, unknown_param: 2) }).to raise_exception(ArgumentError, "unacceptable condition")
    end

    it "should not accept negative condition values" do
      expect(->{ railway.routes_count("C", "C", stops: -4) }).to raise_exception(ArgumentError, "values should be positive numbers")
    end

    it "should accept only numeric condition values" do
      expect(->{ railway.routes_count("C", "C", stops: "#") }).to raise_exception(ArgumentError, "values should be positive numbers")
    end

    it "should not accept :stops and :max_stops at once" do
      expect(->{ railway.routes_count("C", "C", {stops: 1, max_stops: 5}) }).to raise_exception(ArgumentError, "stops and max_stops cannot be used simultaneusly")
    end

    it "should not accept empty conditions" do
      expect(->{ railway.routes_count("C", "C", {}) }).to raise_exception(ArgumentError, "conditions are missing")
    end
  end

  describe "#shortest_path" do
    it "should calculate the distance of the shortest path from town to town" do
      expect(railway.shortest_path "A", "C").to eq 9
      expect(railway.shortest_path "B", "B").to eq 9
    end

    it "should warn, if no route exists" do
      expect(railway.shortest_path("C", "A")).to eq "NO SUCH ROUTE"
    end
  end
end