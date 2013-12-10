require 'spec_helper'

describe Poke::Cli::Base do

  it "should expose the available implementations" do
    described_class.available_implementations.should == {
      "report"  => Poke::Cli::Report,
      "run"     => Poke::Cli::Run,
      "db"      => Poke::Cli::Db,
      "console" => Poke::Cli::Console,
      "help"    => Poke::Cli::Help
    }
  end

  it "should construct with an arg list" do
    sub = described_class.new ["a", "arg", "list"]
    sub.arg_list.should == ["a", "arg", "list"]
  end

  it "should fetch the options 1 index onwards" do
    subject = described_class.new ["a_report_please", "arg1:1", "arg2:2", "arg3:hello", "my", "name", "is", "joe", "arg4:true"]
    subject.options.should == {
      arg1: "1",
      arg2: "2",
      arg3: "hello my name is joe",
      arg4: "true"
    }.with_indifferent_access
  end

end