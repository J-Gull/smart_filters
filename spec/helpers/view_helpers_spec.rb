require "spec_helper"

describe ViewHelpers do
  include ViewHelpers

  before do
    stub_chain(:capture).and_return("")
    ViewHelpers.stub(:concat).with(:html).and_return(:html)
  end

  let(:smart_filter_helper) { smart_filter(AddressBook, :all) }

  describe ".smart_filter" do
    it "has a form tag" do
      smart_filter_helper.should have_tag("form")
    end

    it "has a hidden input tag containing model name" do
      smart_filter_helper.should have_tag("input#model")
    end

    context "when the second argument is :all" do
      let(:text_field_name_attributes) { smart_filter_helper.scan(/<input\b(?>\s+(?:id="([^"]*)"|name="([^"]*)")|[^\s>]+|\s+)*>/).flatten.compact }

      let(:columns) { AddressBook.column_names }

      before do
        columns.delete("id")
        columns.delete("alive")
      end

      it "creates input tags for all columns except booleans" do
        AddressBook.column_names.each do |column|
          text_field_name_attributes.should include("smart_filter[#{column}][value]")
        end
      end
    end

    context "when the second argument is an array of column names" do
      let(:smart_filter_helper) { smart_filter(AddressBook, ['name'])}
      let(:text_field_name_attributes) { smart_filter_helper.scan(/<input\b(?>\s+(?:id="([^"]*)"|name="([^"]*)")|[^\s>]+|\s+)*>/).flatten.compact }

      it "creates input tags for the given columns" do
        text_field_name_attributes.should include("smart_filter[name][value]")
      end
    end

    it "renders a generic partial when no argument is given"

    it "renders a custom partial given explicit argument"
  end
end
