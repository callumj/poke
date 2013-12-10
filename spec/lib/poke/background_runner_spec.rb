require 'spec_helper'

describe Poke::BackgroundRunner do

  describe "construction" do

    it "should set the to_be_killed to be false" do
      described_class.any_instance.stub(:thread_runner)

      sub = described_class.new(Object)
      sub.to_be_killed.should be_false
    end

    it "should init the runner" do
      described_class.any_instance.stub(:thread_runner)

      runner = Object.new
      expect(runner).to receive(:new) do
        :thingo
      end

      sub = described_class.new(runner)
      sub.runner.should == :thingo
    end

    it "should hit thread_runner" do
      described_class.any_instance.stub(:thread_runner) do
        :magic
      end

      sub = described_class.new(Object)
      sub.value.should == :magic
    end

  end

  describe ".kickoff" do

    it "should log an error if no runner is available" do
      expect(Poke::Runners).to receive(:runner) do
        nil
      end

      expect(Poke.app_logger).to receive(:error).with("Will not start background thread, no runner available.")

      described_class.kickoff
    end

    it "should initialize itself, declare the active thread and join" do
      expect_any_instance_of(described_class).to receive(:join)
      described_class.any_instance.stub(:thread_runner)

      runner = Object.new
      expect(runner).to receive(:new)
      expect(Poke::Runners).to receive(:runner) do
        runner
      end

      expect do
        described_class.kickoff
      end.to change { described_class.active_thread }.from(nil)

      described_class.active_thread.should be_a(described_class)
    end

    it "should raise an error if the active thread is still running" do
      thread = Object.new
      expect(thread).to receive(:alive?) do
        true
      end

      expect(described_class).to receive(:active_thread).twice do
        thread
      end

      expect(Poke.app_logger).to receive(:error).with("Runner is active, will not start")

      expect(Poke::Runners).to_not receive(:runner)

      expect do
        described_class.kickoff
      end.to raise_error(described_class::AlreadyRunningError)
    end

  end

end