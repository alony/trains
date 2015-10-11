require './railway'

describe 'Railway' do

  describe "initialization" do
    it "should create a map" do
      expect(->{ Railway.new [[:A, :B, 5], [:B, :C, 7], [:D, :E, 10]] }).not_to raise_exception
    end

    it "should accept only a collection" do
      expect(->{ Railway.new "AB5" }).to raise_exception(ArgumentError, "input should be enumerable")
    end

    it "should not accept negative distances" do
      expect(->{ Railway.new [[:A, :B, 5], [:B, :C, -7]] }).to raise_exception(ArgumentError, "distances can't be negative")
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
        expect(->{ Railway.new ["AB5", "BC7", "DE20"] }).not_to raise_exception
      end

      it "should validate distances" do
        expect(->{ Railway.new ["AB#", "BCD"] }).to raise_exception(ArgumentError, "distance must be numeric")
      end

      it "should not accept negative distances" do
        expect(->{ Railway.new ["AB-5", "CD8"] }).to raise_exception(ArgumentError, "distances can't be negative")
      end
    end
  end

end