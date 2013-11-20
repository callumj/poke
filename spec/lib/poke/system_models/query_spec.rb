require 'spec_helper'

describe Poke::SystemModels::Query do

  it "should require a occurred_at" do
    inst = described_class.new
    expect do
      inst.save
    end.to raise_error(Sequel::ValidationFailed)

    inst.errors.keys.should include :occurred_at
  end

  it "should require a statement" do
    inst = described_class.new
    expect do
      inst.save
    end.to raise_error(Sequel::ValidationFailed)

    inst.errors.keys.should include :statement
  end

  it "should set a statement hash on save" do
    expect(CityHash).to receive(:hash64).with("SELECT * FROM `fun`").and_return(2013)
    inst = described_class.new statement: "SELECT * FROM `fun`", occurred_at: Time.now
    inst.save
    inst.statement_hash.should == 2013

    inst = described_class.find(id: inst.id)
    inst.statement_hash.should == 2013
  end

  describe ".most_recent_statements" do

    it "should be able to find the most recent statements with most recent date" do
      time_point_a = Time.at(190)
      time_point_b = Time.at(180)
      time_point_c = Time.at(120)
      time_point_d = Time.at(220)
      query_1 = described_class.create statement: "SELECT * FROM `oracle`",  occurred_at: time_point_a
      query_2 = described_class.create statement: "SELECT * FROM `mongodb`", occurred_at: time_point_a
      query_3 = described_class.create statement: "SELECT * FROM `mssql`",   occurred_at: time_point_d
      query_4 = described_class.create statement: "SELECT * FROM `raven`",   occurred_at: time_point_c
      query_5 = described_class.create statement: "SELECT * FROM `postgre`", occurred_at: time_point_b
      query_6 = described_class.create statement: "SELECT * FROM `sqlite`",  occurred_at: time_point_d

      res = described_class.most_recent_statements
      res[0].should == time_point_d
      res[1].should =~ ["SELECT * FROM `mssql`", "SELECT * FROM `sqlite`"]
    end

  end

  describe ".conditionally_create" do

    it "should create a new record if none exist" do
      time = Time.at(12)
      hash = {
        statement: "SELECT * FROM `nothing`",
        occurred_at: time,
        user: "callumj",
        host: "127.0.0.1",
        server_id: 19
      }

      record = described_class.conditionally_create hash
      record.reload
      record.statement.should   == hash[:statement]
      record.occurred_at.should == hash[:occurred_at]
      record.user.should        == hash[:user]
      record.host.should        == hash[:host]
      record.server_id.should   == hash[:server_id]
    end

    it "should not create a new record if the same statement exists" do
      time = Time.at(17)
      existing = described_class.create statement: "SELECT * FROM `yolo`", occurred_at: time

      hash = {
        statement: "SELECT * FROM `yolo`",
        occurred_at: time,
        user: "callumj",
        host: "127.0.0.1",
        server_id: 19
      }

      described_class.conditionally_create(hash).should == existing
    end

    it "should create a new record if the same statement exists but on a different schema" do
      time = Time.at(17)
      existing = described_class.create statement: "SELECT * FROM `yolo`", occurred_at: time, schema: "mysql"

      hash = {
        statement: "SELECT * FROM `yolo`",
        occurred_at: time,
        user: "callumj",
        host: "127.0.0.1",
        server_id: 19,
        schema: "performance_schema"
      }

      described_class.conditionally_create(hash).should_not == existing
    end

  end

end