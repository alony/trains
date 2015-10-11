require './railway'

describe 'Railway' do

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
    let(:railway) { Railway.new %w[AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7] }

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
    let(:railway) { Railway.new %w[AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7] }

    it "should count all possible routes" do
      expect(railway.routes_count("A", "C")).to eq 2
    end
  end

  describe "#shortest_path" do
    let(:railway) { Railway.new %w[AB5 BC4 CD8 DC8 DE6 AD5 CE2 EB3 AE7] }

    it "should calculate the distance of the shortest path from town to town" do
      expect(railway.shortest_path "A", "C").to eq 9
      expect(railway.shortest_path "B", "B").to eq 9
    end


  end
end