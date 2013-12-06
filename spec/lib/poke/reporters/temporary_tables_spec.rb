require 'spec_helper'

describe Poke::Reporters::TemporaryTables do

  it "should have a visible name" do
    described_class.visible_name.should == "temporary_tables"
  end

  describe "#results_scope" do

    it "should only include queries with involved temporary tables" do
      expected_query_a = Poke::SystemModels::Query.create statement: "SELECT * FROM fun", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["temporary", "where", "index"], query: expected_query_a

      expected_query_b = Poke::SystemModels::Query.create statement: "SELECT * FROM lolz", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["temporary"], query: expected_query_b

      expected_query_c = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["filesort"], query: expected_query_c
      Poke::SystemModels::QueryExecution.create events: ["temporary"], query: expected_query_c

      not_expected_query = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["where", "filesort"], query: not_expected_query

      subject.results_scope.to_a.map(&:id).should =~ [expected_query_a, expected_query_b, expected_query_c].map(&:id)
    end

    it "should order correctly by slowest" do
      expected_query_a = Poke::SystemModels::Query.create statement: "SELECT * FROM fun", occurred_at: Time.now, execution_time: 1.1
      Poke::SystemModels::QueryExecution.create events: ["temporary", "where", "index"], query: expected_query_a

      expected_query_b = Poke::SystemModels::Query.create statement: "SELECT * FROM lolz", occurred_at: Time.now, execution_time: 9.2
      Poke::SystemModels::QueryExecution.create events: ["temporary"], query: expected_query_b

      expected_query_c = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now, execution_time: 8.3
      Poke::SystemModels::QueryExecution.create events: ["temporary", "filesort"], query: expected_query_c

      not_expected_query = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now, execution_time: 1.0
      Poke::SystemModels::QueryExecution.create events: ["where", "filesort"], query: not_expected_query

      subject.results_scope.to_a.map(&:id).should == [expected_query_b, expected_query_c, expected_query_a].map(&:id)
    end

  end

  describe "#justification_for" do

    it "should detail the table scans involved" do
      expected_query_a = Poke::SystemModels::Query.create statement: "SELECT * FROM fun", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["temporary", "where", "index"], query: expected_query_a, table: "fun"

      expected_query_b = Poke::SystemModels::Query.create statement: "SELECT * FROM lolz", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["temporary"], query: expected_query_b, table: "lolz"

      expected_query_c = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["filesort"], query:  expected_query_c, table: "memes"
      Poke::SystemModels::QueryExecution.create events: ["temporary"], query: expected_query_c, table: "doges"
      Poke::SystemModels::QueryExecution.create events: ["temporary"], query: expected_query_c, table: "magic"

      not_expected_query = Poke::SystemModels::Query.create statement: "SELECT * FROM memes", occurred_at: Time.now
      Poke::SystemModels::QueryExecution.create events: ["where", "filesort"], query: not_expected_query, table: "memes"

      results = subject.results
      found_query_a = results.detect { |obj| obj.id == expected_query_a.id }
      subject.justification_for(found_query_a).should include "Temporary table occurred on ", "fun"

      found_query_b = results.detect { |obj| obj.id == expected_query_b.id }
      subject.justification_for(found_query_b).should include "Temporary table occurred on ", "lolz"

      found_query_c = results.detect { |obj| obj.id == expected_query_c.id }
      subject.justification_for(found_query_c).should include "Temporary table occurred on ", "doges", "magic"
    end

  end

end