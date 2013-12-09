require 'spec_helper'

describe Poke::Cli::Base do

  it "should expose the available implementations" do
    described_class.available_implementations.should == {
      "report"  => Poke::Cli::Report,
      "run"     => Poke::Cli::Run
    }
  end

  it "should construct with an arg list" do
    sub = described_class.new ["a", "arg", "list"]
    sub.arg_list.should == ["a", "arg", "list"]
  end

end