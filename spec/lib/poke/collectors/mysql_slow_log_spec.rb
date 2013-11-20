require 'spec_helper'

describe Poke::Collectors::MysqlSlowLog do

  let(:slow_log_data) do
    file_contents = File.read(File.join(APP_PATH, "spec", "fixtures", "mysql_slow_log.json"))
    ActiveSupport::JSON.decode(file_contents)["data"]
  end

  it "should expose the target_db's scope" do
    target_db = Object.new
    expect(target_db).to receive(:fetch).with("SELECT * FROM #{described_class::TBL_NAMESPACE}").and_return(:scope)

    expect(Poke).to receive(:target_db).and_return(target_db)

    described_class.target_scope.should == :scope
  end

  describe ".process_from_db" do

    it "should select from the target scope" do
      target_db = Object.new
      expect(target_db).to receive(:fetch).with("SELECT * FROM #{described_class::TBL_NAMESPACE}").and_return(:scope)

      expect(Poke).to receive(:target_db).and_return(target_db)

      expect(Poke::Utils::DataPaging).to receive(:mass_select).with(:scope)

      described_class.process_from_db
    end

    it "should return false inside the block if it reaches a point that is older" do
      target_db = Object.new
      expect(target_db).to receive(:fetch).with("SELECT * FROM #{described_class::TBL_NAMESPACE}").and_return(:scope)

      expect(Poke).to receive(:target_db).and_return(target_db)

      time_point = Time.now.utc

      t_1 = slow_log_data.first.with_indifferent_access
      t_2 = slow_log_data[2].merge(start_time: (time_point + 1.minute)).with_indifferent_access
      t_3 = slow_log_data[3].with_indifferent_access
      result_a = [t_1]
      result_b = [t_2]
      result_c = [t_3]

      expect(Poke::Utils::DataPaging).to receive(:mass_select).with(:scope) do |&arg|
        arg.call(result_a).should be_true
        arg.call(result_b).should be_false
      end

      expect(described_class).to receive(:process_slow_entry).once

      described_class.process_from_db
    end

  end

end