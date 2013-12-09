require 'spec_helper'

describe Poke::ReportFormatters::TextTable do

  it "should generate a Terminal::Table from the reporter results" do
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

    tem = Object.new
    expect(tem).to receive(:to_s) { "HELLO" }
    expect(Terminal::Table).to receive(:new).with(heading: ["ID", "execution time", "schema", "statement", "notes"], rows: [[23, 2.3, "table1", "SELECT COUNT(*) FROM `lolz`", "I dunno"]]) do
      tem
    end

    described_class.new(reporter: rep).to_s.should == "HELLO"
  end

end
