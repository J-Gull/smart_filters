require 'spec_helper'

describe SmartFilter do
  before(:all) do
    class AddressBook < ActiveRecord::Base; end
  end

  describe ".contains" do
    it "returns a condition compatible array given column_name and term" do
      AddressBook.send(:contains, 'name', 'hello').should == ["name LIKE ?", "%hello%"]
    end
  end

  describe ".between" do
    it "returns a condition compatible array given column_name and term" do
      AddressBook.send(:between, 'id', '4', '7').should == ["id BETWEEN ? AND ?", {'4' => '7'}]
    end
  end

  describe ".conditions" do
    context "when given an array of conditions and arguments" do
      let(:unmerged_conditions) { [["name LIKE ?", "%hello%"], ["id BETWEEN ? AND ?", {'4' => '7'}], ["name NOT LIKE ?", "%hello%"]] }
      
      it "returns a merged array of all conditions in the first element joined with 'AND' and the arguments in the rest" do
        AddressBook.send(:conditions, unmerged_conditions, "AND").should == ["name LIKE ? AND id BETWEEN ? AND ? AND name NOT LIKE ?", "%hello%", "4", "7", "%hello%"]
      end

      it "returns a merged array of all conditions in the first element joined with 'OR' and the arguments in the rest" do
        AddressBook.send(:conditions, unmerged_conditions, "OR").should == ["name LIKE ? OR id BETWEEN ? AND ? OR name NOT LIKE ?", "%hello%", "4", "7", "%hello%"]
      end
    end
  end

  describe ".smart_filter" do
    let(:bob) { Factory(:address_book, :name => "Bob Martin", :zipcode => 12345) }
    let(:david) { Factory(:address_book, :name => "David Henderson", :zipcode => 12347) }
    let(:zheimer) { Factory(:address_book, :name => "Clarke Zheimer", :zipcode => 12348) }


    before(:each) do
      bob.save!
      david.save!
      zheimer.save!
    end

    it "returns all records if the criteria is unknown" do
      AddressBook.smart_filter({:name => {["magic"] => ["abracadabra"]}}, "AND").should == AddressBook.find(:all)
    end
    
    it "returns an empty array if the column doesn't exist" do
      AddressBook.smart_filter({:magician => {["magic"] => ["abracadabra"]}}, "AND").should == []
    end

    context "when the argument contains more than one filter" do
      context "of different columns" do
        it "returns the record matching all the criteria" do
          AddressBook.smart_filter({:name => {["contains"] => ["Bob"]},
                                    :address => {["contains"] => ["Abracarab"]}}, "AND").should be_empty
          AddressBook.smart_filter({:name => {["contains"] => ["Bob"]},
                                    :alive => "f"}, "AND").should have(1).item
        end
      end

      context "of the same column" do
        it "returns the record matching all the criteria" do
          AddressBook.smart_filter({:name => {["contains", "contains"] => ["Bob", "Martin"]}}, "AND").should have(1).item
        end
      end
    end


    context "when the column to apply smart filtering is string or text" do
      context "when the criteria is 'contains'" do

        it "returns the record with the column that contains the given string" do
          AddressBook.smart_filter({:name => {["contains"] => ["Bob"]}}, "AND").first.name.should == bob.name
          AddressBook.smart_filter({:name => {["contains"] => ["Bob"]}}, "AND").first.name.should include(bob.name.split.first)
        end

      end

      context "when the criteria is 'is'" do

        it "returns the record with the column of the exact given string" do
          AddressBook.smart_filter({:name => {["is"] => ["Bob Martin"]}}, "AND").first.name.should == bob.name
        end

      end

      context "when the criteria is 'does_not_contain'" do

        it "returns the record with the column that does not contain the given string" do
          AddressBook.smart_filter({:name => {["does_not_contain"] => ["Bob Martin"]}}, "AND").first.name.should_not == bob.name
        end

      end

      context "when the criteria is starts_with" do

        it "returns the record with the column that starts with the given string" do
          AddressBook.smart_filter({:name => {["starts_with"] => ["David"]}}, "AND").first.name.should =~ /^David[.]*/
        end

      end

      context "when the criteria is ends_with" do

        it "returns the record with the column that ends with the given string" do
          AddressBook.smart_filter({:name => {["ends_with"] => ["Henderson"]}}, "AND").first.name.should =~ /[.]*Henderson$/
        end

      end

    end

    context "when the column to apply smart filtering is integer" do

      context "when the criteria is equals_to" do

        it "returns records with the column that equals the given integer" do
          AddressBook.smart_filter({:zipcode => {["equals_to"] => ["12345"]}}, "AND").first.zipcode.should == 12345
        end

      end

      context "when the criteria is greater_than" do
        it "returns records with the column that is greater than the given integer" do
          AddressBook.smart_filter({:zipcode => {["greater_than"] => ["12345"]}}, "AND").first.zipcode.should > 12345
        end
      end

      context "when the criteria is less_than" do
        it "returns records with the column that is less than the given integer" do
          AddressBook.smart_filter({:zipcode => {["less_than"] => ["12346"]}}, "AND").first.zipcode.should < 12346
        end
      end

      context "when the criteria is between" do
        it "returns records with the column that is between the the given integers" do
          AddressBook.smart_filter({:zipcode => {"between" => ["12343", "12348"]}}, "AND").should have(3).items
          AddressBook.smart_filter({:zipcode => {"between" => ["12343", "12348"]}}, "AND").each do |contact|
            contact.should satisfy { |c| c.zipcode >= 12343 && c.zipcode <= 12348 }
          end
        end
      end

    end

    context "when the column to apply smart filtering is boolean" do

      context "when the criteria is false" do
        let(:wright) { Factory(:address_book, :name => 'Orville Wright', :alive => "f") }
        
        before { wright.save! }
        
        it "returns records with false boolean column" do
          AddressBook.smart_filter({:alive => "f"}, "AND").should have_at_least(1).item
          AddressBook.smart_filter({:alive => "f"}, "AND").should include(AddressBook.find_by_name('Orville Wright'))
        end
      end

      context "when the criteria is true" do
        let(:steve) { Factory(:address_book, :name => 'Steve Jobs', :alive => "t") }
        
        before { steve.save! }
        
        it "returns records with true boolean column" do
          AddressBook.smart_filter({:alive => "t"}, "AND").should have_at_least(1).item
          AddressBook.smart_filter({:alive => "t"}, "AND").should include(AddressBook.find_by_name('Steve Jobs'))
        end
      end

    end

    context "when the column to apply smart filtering is date or date/time" do

      context "when the criteria is on" do
        let(:matz) { Factory(:address_book, :name => "Yukihiro Matsumoto", :created_at => Time.now.localtime.strftime("%Y-%m-%d")) }

        before { matz.save! }

        it "returns records with column corresponding on the given date" do
          AddressBook.smart_filter({:created_at => {["on"] => [Time.now.localtime.strftime("%Y-%m-%d")]}}, "AND").should have_at_least(1).item
        end
      end

      context "when the criteria is before" do
        let(:flanagan) { Factory(:address_book, :name => "David Flanagan", :created_at => Time.now.localtime.strftime("1980-%m-%d")) }

        before { flanagan.save! }

        it "returns records with column that corresponds before the given date" do
          AddressBook.smart_filter({:created_at => {["before"] => [Time.now.localtime.strftime("%Y-%m-%d")]}}, "AND").should have_at_least(1).item
        end
      end

      context "when the criteria is after" do
        let(:obie) { Factory(:address_book, :name => "Obie Fernandez", :created_at => Time.now.localtime.strftime("2090-%m-%d")) }

        before { obie.save! }

        it "returns records with column that corresponds after the given date" do
          AddressBook.smart_filter({:created_at => {["after"] => [Time.now.localtime.strftime("2090-%m-%d")]}}, "AND").should have_at_least(1).item
        end
      end

    end

    context "when the rule is OR" do
      it "returns records matching either one of the filter criteria" do
        AddressBook.smart_filter({:name => {["contains"] => ["Bob"]},
                                  :address => {["contains"] => ["Abracarab"]}}, "OR").should have(1).item

        AddressBook.smart_filter({:name => {["contains", "contains"] => ["Bob", "Henderson"]}},
                                  "OR").should have(2).items
      end
    end

  end
end
