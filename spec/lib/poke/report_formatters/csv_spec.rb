require 'spec_helper'

describe Poke::ReportFormatters::Csv do

  it "should generate a CSV from the reporter results" do
    query = Object.new
    expect(query).to receive(:id)             { 23 }
    expect(query).to receive(:execution_time) { 2.3 }
    expect(query).to receive(:schema)         { "table1" }
    expect(query).to receive(:statement)      { "SELECT COUNT(*) FROM `lolz`" }

    rep = Poke::Reporters::Base.new
    expect(rep).to receive(:results) { [query] }
    expect(rep).to receive(:justification_for).with(query) do
      "I dunno"
    end

    received_block = nil
    expect(CSV).to receive(:generate) do |&block|
      received_block = block
    end

    described_class.new(reporter: rep).to_s

    csv_receiver = Object.new
    csv_set = []
    expect(csv_receiver).to receive(:<<).twice do |ary|
      csv_set << ary
    end

    received_block.call csv_receiver
    csv_set.should == [
      ["ID", "execution time", "schema", "statement", "notes"],
      [23, 2.3, "table1", "SELECT COUNT(*) FROM `lolz`", "I dunno"]
    ]
  end

end
