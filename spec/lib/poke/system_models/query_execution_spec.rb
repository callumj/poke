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

end