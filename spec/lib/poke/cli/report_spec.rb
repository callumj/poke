require 'spec_helper'

describe Poke::Cli::Report do

  subject { described_class.new ["a_report_please", "arg1:1", "arg2:2", "arg3:hello", "my", "name", "is", "joe", "arg4:true"] }

  it "should fetch the report name from the first arg" do
    subject.report_name.should == "a_report_please"
  end

  it "should fetch the options" do
    subject.options.should == {
      arg1: "1",
      arg2: "2",
      arg3: "hello my name is joe",
      arg4: "true"
    }.with_indifferent_access
  end

  describe "#run" do

    it "should exit if the report_name is not present" do
      expect(subject).to receive(:report_name) { nil }
      expect(Poke::ReportFormatters::Base).to_not receive(:available_implementations)

      subject.run.should be_false
    end

    it "should exit if the formatter is not present" do
      expect(Poke::Reporters::Base).to receive(:available_implementations) do
        {
          "a_report_please" => Object
        }
      end

      expect(Poke::ReportFormatters::Base).to receive(:available_implementations) do
        {}
      end

      subject.run.should be_false
    end

    it "should exit if there is no runner" do
      expect(subject).to receive(:format) { "formatey" }
      expect(Poke::Reporters::Base).to receive(:available_implementations) do
        {
          "a_report_please" => Object
        }
      end

      expect(Poke::ReportFormatters::Base).to receive(:available_implementations) do
        {
          "formatey" => Object
        }
      end

      expect(Poke::Runners).to receive(:runner) { nil }
      subject.run.should be_false
    end

    it "should invoke the runner and dump the report" do
      reporter = Object.new
      expect(reporter).to receive(:new) { :report_a }

      formatter_inst  = Object.new
      expect(formatter_inst).to receive(:to_s) { "STRING!" }
      formatter_klass = Object.new
      expect(formatter_klass).to receive(:new).with(reporter: :report_a) do
        formatter_inst
      end

      expect(subject).to receive(:format) { "formatey" }
      expect(Poke::Reporters::Base).to receive(:available_implementations) do
        {
          "a_report_please" => reporter
        }
      end

      expect(Poke::ReportFormatters::Base).to receive(:available_implementations) do
        {
          "formatey" => formatter_klass
        }
      end

      runner_inst  = Object.new
      expect(runner_inst).to receive(:run)
      runner_klass = Object.new
      expect(runner_klass).to receive(:new) { runner_inst }
      expect(Poke::Runners).to receive(:runner) { runner_klass }

      subject.run.should == "STRING!"
    end

  end

  describe "#format" do

    it "should fetch the format" do
      expect(subject).to receive(:options) do 
        {
          thing:  true,
          format: "lolz"
        }
      end

      subject.format.should == "lolz"
    end

    it "should fall back to text_table" do
      subject.format.should == "text_table"
    end

  end

end
