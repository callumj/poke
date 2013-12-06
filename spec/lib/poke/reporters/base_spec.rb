require 'spec_helper'

describe Poke::Reporters::Base do

  it "should expose all known reporters" do
    described_class.available_implementations.should == {
      "temporary_tables" => Poke::Reporters::TemporaryTables,
      "table_scans"      => Poke::Reporters::TableScans
    }
  end

  it "should expect subclasses to implement results_scope" do
    expect do
      subject.results_scope
    end.to raise_error(NotImplementedError)
  end

  it "should store provided hash options" do
    sub = described_class.new opt: :value
    sub.options.should == {opt: :value}
  end

  it "should provide nil for a justification" do
    subject.justification_for(Object.new).should be_nil
  end

end