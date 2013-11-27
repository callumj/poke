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

end
