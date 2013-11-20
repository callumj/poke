require 'spec_helper'

describe Poke::SystemModels::Query do

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