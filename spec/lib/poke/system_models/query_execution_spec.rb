require 'spec_helper'

describe Poke::SystemModels::QueryExecution do

  it "should be able to reference a query" do
    query = Poke::SystemModels::Query.create statement: "SELECT * FROM table", occurred_at: Time.now
    subject = described_class.new query: query
    subject.query.should == query

    subject.save

    query.query_executions.should include subject

    subject = described_class.find id: subject.id
    subject.query.should == query
  end

  it "should be able to reference execution events" do
    event_a = Poke::SystemModels::ExecutionEvent.conditionally_create("temporary")
    event_b = Poke::SystemModels::ExecutionEvent.conditionally_create("filesort")
    event_c = Poke::SystemModels::ExecutionEvent.conditionally_create("index")

    subject = described_class.create
    subject.add_execution_event event_a
    subject.add_execution_event event_b
    subject.save

    subject = described_class.find id: subject.id
    subject.execution_events.to_a.should =~ [event_a, event_b]
  end

  describe "hashing" do

    it "should be able to hash all needed" do
      subject = described_class.new select_method: "SIMPLE", index_method: "ref", selected_index: "PRIMARY"
      expect(CityHash).to receive(:hash64).with("SIMPLE")  { 1975 }
      expect(CityHash).to receive(:hash64).with("ref")     { 1901 }
      expect(CityHash).to receive(:hash64).with("PRIMARY") { 1999 }

      subject.save

      subject.select_method_hash.should  == 1975
      subject.index_method_hash.should   == 1901
      subject.selected_index_hash.should == 1999
    end

    it "should not hash nil values" do
      subject = described_class.new select_method: "SIMPLE", selected_index: "PRIMARY"
      expect(CityHash).to receive(:hash64).with("SIMPLE")  { 1975 }
      expect(CityHash).to receive(:hash64).with("PRIMARY") { 1999 }

      subject.save

      subject.select_method_hash.should  == 1975
      subject.index_method_hash.should   be_nil
      subject.selected_index_hash.should == 1999
    end

  end

end