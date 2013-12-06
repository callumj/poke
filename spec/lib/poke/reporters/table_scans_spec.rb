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

  describe "#justification_for" do

    it "should detail the table scans involved" do
      expected_query_a = Poke::SystemModels::Query.create statement: "SELECT * FROM fun", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create join_method: "ALL", query: expected_query_a, table: "employees"

      expected_query_b = Poke::SystemModels::Query.create statement: "SELECT * FROM lolz", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create join_method: "const",  query: expected_query_b, table: "employees"
      Poke::SystemModels::QueryExecution.create join_method: "ALL",    query: expected_query_b, table: "stores"
      Poke::SystemModels::QueryExecution.create join_method: "system", query: expected_query_b, table: "inventory"
      Poke::SystemModels::QueryExecution.create join_method: "ALL",    query: expected_query_b, table: "purchases"

      not_expected_query = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create join_method: "ref", query: not_expected_query

      results = subject.results
      found_query_a = results.detect { |obj| obj.id == expected_query_a.id }
      subject.justification_for(found_query_a).should include "Table scan occurred on ", "employees"

      found_query_b = results.detect { |obj| obj.id == expected_query_b.id }
      subject.justification_for(found_query_b).should include "Table scan occurred on ", "stores", "purchases"
    end

  end

end