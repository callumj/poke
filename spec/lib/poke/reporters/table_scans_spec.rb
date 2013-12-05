require 'spec_helper'

describe Poke::Reporters::TableScans do

  it "should have a visible name" do
    described_class.visible_name.should == "table_scans"
  end

  describe "#results_scope" do

    it "should only include queries that caused ALL join_methods" do
      expected_query_a = Poke::SystemModels::Query.create statement: "SELECT * FROM fun", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create join_method: "ALL", query: expected_query_a

      expected_query_b = Poke::SystemModels::Query.create statement: "SELECT * FROM lolz", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create join_method: "const",  query: expected_query_b
      Poke::SystemModels::QueryExecution.create join_method: "ALL",    query: expected_query_b
      Poke::SystemModels::QueryExecution.create join_method: "system", query: expected_query_b

      not_expected_query = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create join_method: "ref", query: not_expected_query

      subject.results_scope.to_a.map(&:id).should =~ [expected_query_a, expected_query_b].map(&:id)
    end

  end

end