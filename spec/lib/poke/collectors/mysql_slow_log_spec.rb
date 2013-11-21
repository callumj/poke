require 'spec_helper'
require 'timecop'

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

      Timecop.freeze(time_point) do
        described_class.process_from_db
      end
    end

    it "should skip an entry if the entry is less than the most recent occurrence" do
      target_db = Object.new
      expect(target_db).to receive(:fetch).with("SELECT * FROM #{described_class::TBL_NAMESPACE}").and_return(:scope)

      expect(Poke).to receive(:target_db).and_return(target_db)

      time_point = Time.at(19)
      expect(Poke::SystemModels::Query).to receive(:most_recent_statements) do 
        [time_point, []]
      end

      t_1 = slow_log_data.first.merge(start_time: (time_point - 1.minute)).with_indifferent_access
      t_2 = slow_log_data[2].merge(start_time: (time_point - 3.minute)).with_indifferent_access
      t_3 = slow_log_data[3].merge(sql_text: "t_3", start_time: (time_point + 1.minute)).with_indifferent_access
      t_4 = slow_log_data[4].merge(sql_text: "t_4", start_time: time_point).with_indifferent_access
      result_a = [t_1]
      result_b = [t_2]
      result_c = [t_3, t_4]

      expect(Poke::Utils::DataPaging).to receive(:mass_select).with(:scope) do |&arg|
        arg.call(result_a).should be_true
        arg.call(result_b).should be_true
        arg.call(result_c).should be_true
      end

      received = []
      expect(described_class).to receive(:process_slow_entry).twice do |hash|
        received << hash
      end

      described_class.process_from_db
      received.map { |hash| hash[:statement] }.should =~ ["t_3", "t_4"]
    end

    it "should skip an entry if the timing is the same and statement is already known" do
      target_db = Object.new
      expect(target_db).to receive(:fetch).with("SELECT * FROM #{described_class::TBL_NAMESPACE}").and_return(:scope)

      expect(Poke).to receive(:target_db).and_return(target_db)

      time_point = Time.at(19)
      expect(Poke::SystemModels::Query).to receive(:most_recent_statements) do 
        [time_point, ["t_4"]]
      end

      t_1 = slow_log_data.first.merge(start_time: (time_point - 1.minute)).with_indifferent_access
      t_2 = slow_log_data[2].merge(start_time: (time_point - 3.minute)).with_indifferent_access
      t_3 = slow_log_data[3].merge(sql_text: "t_3", start_time: (time_point + 1.minute)).with_indifferent_access
      t_4 = slow_log_data[4].merge(sql_text: "t_4", start_time: time_point).with_indifferent_access
      result_a = [t_1]
      result_b = [t_2]
      result_c = [t_3, t_4]

      expect(Poke::Utils::DataPaging).to receive(:mass_select).with(:scope) do |&arg|
        arg.call(result_a).should be_true
        arg.call(result_b).should be_true
        arg.call(result_c).should be_true
      end

      received = []
      expect(described_class).to receive(:process_slow_entry).once do |hash|
        received << hash
      end

      described_class.process_from_db
      received.map { |hash| hash[:statement] }.should == ["t_3"]
    end

    it "should pass a converted object into .process_slow_entry" do
      target_db = Object.new
      expect(target_db).to receive(:fetch).with("SELECT * FROM #{described_class::TBL_NAMESPACE}").and_return(:scope)

      expect(Poke).to receive(:target_db).and_return(target_db)

      time_point = Time.now.utc

      t_1 = slow_log_data.first.with_indifferent_access
      result_a = [t_1]

      expect(Poke::Utils::DataPaging).to receive(:mass_select).with(:scope) do |&arg|
        arg.call(result_a).should be_true
      end

      received = nil
      expect(described_class).to receive(:process_slow_entry).once do |val|
        received = val
      end

      described_class.process_from_db

      received[:occurred_at].should == t_1[:start_time]
      received[:user].should == "funtimes"
      received[:host].should == "10.10.24.242"
      received[:rows_sent].should == 1
      received[:rows_examined].should == 1771354
      received[:schema].should == "funtimes_production"
      received[:last_insert_id].should == 0
      received[:server_id].should == 28
      received[:statement].should == "SELECT  `cars`.* FROM `cars` INNER JOIN `activity_cars` ON `activity_cars`.`car_id` = `cars`.`id` INNER JOIN `activities` ON `activities`.`id` = `activity_cars`.`activity_id` WHERE `cars`.`target_id` = 2831 AND `cars`.`target_type` = 'User' AND `cars`.`type` = 'C63' AND `activities`.`subject_type` = 'Drive' AND `activities`.`subject_id` = 90646 ORDER BY `cars`.`position` DESC, `activities`.`enacted_at` DESC, `activities`.`id` DESC LIMIT 1"
    end

  end

end