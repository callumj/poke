require 'spec_helper'

describe Poke::Analyzers::MysqlExplain do

  it "should strip unusable statements & cache" do
    query = Object.new
    expect(query).to receive(:statement).once do
      <<-eos
        BEGIN;
        SELECT * FROM `table` WHERE col1 = 1;
        COMMIT;
      eos
    end

    subject = described_class.new(query)
    3.times { subject.explainable_query.should == "SELECT * FROM `table` WHERE col1 = 1;" }
  end

  it "should hit the DB for a schema switch and EXPLAIN" do
    query = Object.new
    expect(query).to receive(:schema) { "mongodb" }

    subject = described_class.new(query)
    expect(subject).to receive(:explainable_query) { "SELECT BLA" }

    query_result = Object.new
    expect(query_result).to receive(:all) { ["hello"] }
    
    db_result = Object.new
    expect(db_result).to receive(:[]).with("EXPLAIN SELECT BLA") { query_result }

    db = Object.new
    expect(db).to receive(:<<).with("USE `mongodb`") { db_result }

    expect(Poke).to receive(:target_db) { db }

    3.times { subject.explain_result.should == ["hello"] }
  end

  describe "#attach_to_query" do

    it "should add a query execution if none exist" do
      array = []
      expect(array).to receive(:eager).with(:execution_events).twice { [] }

      query = Object.new
      expect(query).to receive(:query_executions).exactly(3).times { array }
      expect(query).to receive(:add_query_execution).with({order: 0, id: 1})
      expect(query).to receive(:add_query_execution).with({order: 1, id: 2})

      subject = described_class.new(query)
      expect(subject).to receive(:executions) do
        [
          {order: 0, id: 1},
          {order: 1, id: 2}
        ]
      end

      subject.attach_to_query
    end

    it "should replace existing query executions" do
      replaceable = Object.new
      expect(replaceable).to receive(:order).exactly(3).times { 0 }
      expect(replaceable).to receive(:update).with({order: 0, id: 1})
      expect(replaceable).to receive(:events) { [] }

      array = [replaceable]
      expect(array).to receive(:eager).with(:execution_events).twice { [replaceable] }

      query = Object.new
      expect(query).to receive(:query_executions).exactly(3).times { array }
      expect(query).to receive(:add_query_execution).with({order: 1, id: 2})

      subject = described_class.new(query)
      expect(subject).to receive(:executions) do
        [
          {order: 0, id: 1, events: []},
          {order: 1, id: 2}
        ]
      end

      subject.attach_to_query
    end

    it "should be able to add existing events" do
      obj = Object.new
      expect(Poke::SystemModels::ExecutionEvent).to receive(:conditionally_create).with("thing") { obj }

      replaceable = Object.new
      expect(replaceable).to receive(:order).exactly(2).times { 0 }
      expect(replaceable).to receive(:update).with({order: 0, id: 1})
      expect(replaceable).to receive(:events) { [] }
      expect(replaceable).to receive(:add_execution_event).with(obj)

      array = [replaceable]
      expect(array).to receive(:eager).with(:execution_events).once { [replaceable] }

      query = Object.new
      expect(query).to receive(:query_executions).exactly(2).times { array }

      subject = described_class.new(query)
      expect(subject).to receive(:executions) do
        [
          {order: 0, id: 1, events: ["thing"]},
        ]
      end

      subject.attach_to_query
    end

    it "should be able to remove no longer existing events" do
      obj = Object.new
      expect(Poke::SystemModels::ExecutionEvent).to receive(:conditionally_create).with("thing") { obj }

      replaceable = Object.new
      expect(replaceable).to receive(:order).exactly(2).times { 0 }
      expect(replaceable).to receive(:update).with({order: 0, id: 1})
      expect(replaceable).to receive(:events) { ["thing"] }
      expect(replaceable).to receive(:remove_execution_event).with(obj)

      array = [replaceable]
      expect(array).to receive(:eager).with(:execution_events).once { [replaceable] }

      query = Object.new
      expect(query).to receive(:query_executions).exactly(2).times { array }

      subject = described_class.new(query)
      expect(subject).to receive(:executions) do
        [
          {order: 0, id: 1, events: []},
        ]
      end

      subject.attach_to_query
    end

    it "should not touch existing events" do
      replaceable = Object.new
      expect(replaceable).to receive(:order).exactly(2).times { 0 }
      expect(replaceable).to receive(:update).with({order: 0, id: 1})
      expect(replaceable).to receive(:events) { ["thing"] }

      array = [replaceable]
      expect(array).to receive(:eager).with(:execution_events).once { [replaceable] }

      query = Object.new
      expect(query).to receive(:query_executions).exactly(2).times { array }

      subject = described_class.new(query)
      expect(subject).to receive(:executions) do
        [
          {order: 0, id: 1, events: ["thing"]},
        ]
      end

      subject.attach_to_query
    end

    it "should kill off remaining events that aren't known" do
      removable = Object.new
      expect(removable).to receive(:order).exactly(3).times { 2 }
      expect(removable).to receive(:delete)

      array = [removable]
      expect(array).to receive(:eager).with(:execution_events).twice { [removable] }

      query = Object.new
      expect(query).to receive(:query_executions).exactly(3).times { array }
      expect(query).to receive(:add_query_execution).with({order: 0, id: 1, events: []})
      expect(query).to receive(:add_query_execution).with({order: 1, id: 2})

      subject = described_class.new(query)
      expect(subject).to receive(:executions) do
        [
          {order: 0, id: 1, events: []},
          {order: 1, id: 2}
        ]
      end

      subject.attach_to_query
    end

  end

  describe "#executions" do

    it "should order them as the DB spits them out" do
      subject = described_class.new(nil)
      expect(subject).to receive(:explain_result) do
        [
          {table: "1"},
          {table: "2"},
          {table: "1"}
        ]
      end

      subject.executions[0][:order].should == 0
      subject.executions[0][:table].should == "1"

      subject.executions[1][:order].should == 1
      subject.executions[1][:table].should == "2"

      subject.executions[2][:order].should == 2
      subject.executions[2][:table].should == "1"
    end

    it "should map the types across" do
      subject = described_class.new(nil)
      expect(subject).to receive(:explain_result) do
        [
          {
            select_type:   "1_select_type",
            ref:           "1_ref",
            table:         "1_table",
            possible_keys: "1_key_a, 1_key_b,1_key_c",
            key:           "1_key",
            key_len:       1,
            rows: 101,
            Extra:        "1_event_a;1_event_b; 1_event_c"
          },
          {
            select_type:   "2_select_type",
            ref:           "2_ref",
            table:         "2_table",
            possible_keys: "2_key_a, 2_key_b,2_key_c",
            key:           "2_key",
            key_len:       2,
            rows: 202,
            Extra:        "2_event_a;2_event_b; 2_event_c"
          }
        ]
      end

      expect(subject).to receive(:sanitise_events).with("1_event_a;1_event_b; 1_event_c") do
        ["1", "2", "3"]
      end

      expect(subject).to receive(:sanitise_events).with("2_event_a;2_event_b; 2_event_c") do
        ["4", "5", "6"]
      end

      subject.executions.should == [
        {
          order: 0,
          select_method:    "1_select_type",
          index_method:     "1_ref",
          table:            "1_table",
          possible_indexes: ["1_key_a", "1_key_b", "1_key_c"],
          selected_index:   "1_key",
          index_length_used: 1,
          rows_examined:     101,
          events:            ["1", "2", "3"]
        },
        {
          order: 1,
          select_method:    "2_select_type",
          index_method:     "2_ref",
          table:            "2_table",
          possible_indexes: ["2_key_a", "2_key_b", "2_key_c"],
          selected_index:   "2_key",
          index_length_used: 2,
          rows_examined:     202,
          events:            ["4", "5", "6"]
        }
      ]
    end

  end

  describe ".sanitise_events" do

    it "should return a empty array when Nil given" do
      described_class.sanitise_events(nil).should == []
    end

    it "should return a empty array when empty given" do
      described_class.sanitise_events([]).should == []
    end

    it "should split out semi-colon delimited" do
      described_class.sanitise_events("hello;my; people;").should =~ ["hello", "my", "people"]
    end

    it "should extract MySQL's Using" do
      described_class.sanitise_events("hello;my; people; Using index; Using where;").should =~ ["hello", "my", "people", "index", "where"]
    end

  end

end
