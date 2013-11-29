require 'spec_helper'

describe Poke::Runners::Mysql do

  describe "#obtain_queries" do

    it "should not run collection if the mode isn't set" do
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.collection_mode") do
        nil
      end

      expect(Poke::Collectors::MysqlSlowLog).to_not receive(:new)

      subject.obtain_queries
    end

    it "should process_from_file if mode is file" do
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.collection_mode") do
        "file"
      end
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.slow_log_file") do
        "A FILE"
      end

      msyql_slow_log = Object.new
      expect(msyql_slow_log).to receive(:process_from_file).with("A FILE")
      expect(Poke::Collectors::MysqlSlowLog).to receive(:new) { msyql_slow_log }

      subject.obtain_queries
    end

    it "should handle Argument Errors" do
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.collection_mode") do
        "file"
      end
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.slow_log_file") do
        "A FILE"
      end

      arg_error = ArgumentError.new("I ERROR")

      msyql_slow_log = Object.new
      expect(msyql_slow_log).to receive(:process_from_file).with("A FILE") do
        raise arg_error
      end
      expect(Poke::Collectors::MysqlSlowLog).to receive(:new) { msyql_slow_log }

      expect(subject.logger).to receive(:error) do |msg|
        msg.should include "I ERROR"
      end

      subject.obtain_queries
    end

    it "should handle SlowLogFileNotPresent Errors" do
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.collection_mode") do
        "file"
      end
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.slow_log_file") do
        "A FILE"
      end

      arg_error = Poke::Collectors::MysqlSlowLog::SlowLogFileNotPresent.new("I ERROR")

      msyql_slow_log = Object.new
      expect(msyql_slow_log).to receive(:process_from_file).with("A FILE") do
        raise arg_error
      end
      expect(Poke::Collectors::MysqlSlowLog).to receive(:new) { msyql_slow_log }

      expect(subject.logger).to receive(:error) do |msg|
        msg.should include "I ERROR"
      end

      subject.obtain_queries
    end

    it "should bubble up other errors" do
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.collection_mode") do
        "file"
      end
      expect(Poke::Config).to receive(:[]).with("#{described_class::CONFIG_NAMESPACE}.slow_log_file") do
        "A FILE"
      end

      arg_error = NoMethodError.new("I ERROR")

      msyql_slow_log = Object.new
      expect(msyql_slow_log).to receive(:process_from_file).with("A FILE") do
        raise arg_error
      end
      expect(Poke::Collectors::MysqlSlowLog).to receive(:new) { msyql_slow_log }

      expect(subject.logger).to_not receive(:error)

      expect do
        subject.obtain_queries
      end.to raise_error(arg_error)
    end

  end

end