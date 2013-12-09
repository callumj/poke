require 'spec_helper'

describe Poke::Cli do

  describe "#invoke" do

    it "should initialize the matching key value" do
      inst = Object.new
      expect(inst).to receive(:run)

      klass = Object.new
      expect(klass).to receive(:new).with(["a", "arg", "list"]) do
        inst
      end
      expect(Poke::Cli::Base).to receive(:available_implementations) do
        {"a_task" => klass}
      end

      described_class.invoke "a_task", ["a", "arg", "list"]
    end

    it "should STDOUT the value if a String" do
      inst = Object.new
      expect(inst).to receive(:run) do
        "hello joe!"
      end

      klass = Object.new
      expect(klass).to receive(:new).with(["a", "arg", "list"]) do
        inst
      end
      expect(Poke::Cli::Base).to receive(:available_implementations) do
        {"a_task" => klass}
      end

      expect(STDOUT).to receive(:puts).with("hello joe!")

      described_class.invoke "a_task", ["a", "arg", "list"]
    end

    it "should not STDOUT a non string return value" do
      inst = Object.new
      expect(inst).to receive(:run) do
        true
      end

      klass = Object.new
      expect(klass).to receive(:new).with(["a", "arg", "list"]) do
        inst
      end
      expect(Poke::Cli::Base).to receive(:available_implementations) do
        {"a_task" => klass}
      end

      expect(STDOUT).to_not receive(:puts)

      described_class.invoke "a_task", ["a", "arg", "list"]
    end

  end

end