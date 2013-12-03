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
      expect_any_instance_of(described_class).to receive(:thread_runner) do
        :magic
      end

      sub = described_class.new(Object)
      sub.value.should == :magic
    end

  end

  describe "#thread_runner" do

    it "should hit perform_task" do
      described_class.any_instance.stub(:perform_task)

      runner = Object.new
      expect(runner).to receive(:new)

      sub = described_class.new(runner)
      expect(sub).to receive(:perform_task)
      sub.thread_runner
    end

  end

  describe "#perform_task" do

    before :each do
      described_class.any_instance.stub(:thread_runner)
    end

    it "should not loop if it is to be killed" do
      runner_inst = Object.new
      expect(runner_inst).to_not receive(:run)

      runner  = Object.new
      expect(runner).to receive(:new) do
        runner_inst
      end

      sub = described_class.new(runner)
      expect(sub).to receive(:to_be_killed) do
        true
      end

      sub.perform_task
    end

    it "should sleep between runs" do
      runner_inst = Object.new
      expect(runner_inst).to receive(:run)

      runner  = Object.new
      expect(runner).to receive(:new) do
        runner_inst
      end

      time = 0
      sub = described_class.new(runner)
      expect(sub).to receive(:to_be_killed).exactly(3).times do
        time += 1
        if time == 3
          true
        else
          false
        end
      end

      expect(sub).to receive(:sleep).with(described_class::SLEEP_BETWEEN)

      sub.perform_task
    end

    it "should quit immediately if to_be_killed" do
      runner_inst = Object.new
      expect(runner_inst).to receive(:run)

      runner  = Object.new
      expect(runner).to receive(:new) do
        runner_inst
      end

      time = 0
      sub = described_class.new(runner)
      expect(sub).to receive(:to_be_killed).exactly(2).times do
        time += 1
        if time == 2
          true
        else
          false
        end
      end

      expect(sub).to_not receive(:sleep)

      sub.perform_task
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