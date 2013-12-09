require 'spec_helper'

describe Poke::ReportFormatters::Base do

  it "should expose the available implementations" do
    described_class.available_implementations.should == {
      "csv"         => Poke::ReportFormatters::Csv,
      "text_table"  => Poke::ReportFormatters::TextTable
    }
  end

  describe "construction" do

    it "should require a reporter instance" do
      expect do
        described_class.new reporter: nil
      end.to raise_error(ArgumentError)

      expect do
        described_class.new reporter: Object.new
      end.to raise_error(ArgumentError)
    end

    it "should store the reporter and options" do
      rep = Poke::Reporters::TemporaryTables.new
      sub = described_class.new reporter: rep, lol: true
      sub.reporter.should == rep
      sub.options.should == {lol: true}
    end

  end

  it "should expect subclasses to implement to_s" do
    rep = Poke::Reporters::TemporaryTables.new
    sub = described_class.new reporter: rep, lol: true
    expect do
      sub.to_s
    end.to raise_error(NotImplementedError)
  end

  it "should allow for writing to file" do
    rep = Poke::Reporters::TemporaryTables.new
    sub = described_class.new reporter: rep, lol: true
    expect(sub).to receive(:to_s) do
      "A FILE"
    end

    f_descriptor = Object.new
    expect(f_descriptor).to receive(:write).with("A FILE")
    sub.to_file f_descriptor
  end

end
