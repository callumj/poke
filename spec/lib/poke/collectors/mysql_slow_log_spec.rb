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

  describe "#process_from_db" do

    it "should select from the target scope" do
      target_db = Object.new
      expect(target_db).to receive(:fetch).with("SELECT * FROM #{described_class::TBL_NAMESPACE}").and_return(:scope)

      expect(Poke).to receive(:target_db).and_return(target_db)

      expect(Poke::Utils::DataPaging).to receive(:mass_select).with(:scope)

      subject.process_from_db
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

      expect(subject).to receive(:process_native_entry).once

      Timecop.freeze(time_point) do
        subject.process_from_db
      end
    end

  end

  describe "#process_from_file" do

    it "should raise ArgumentError if no file is passed in" do
      expect do
        subject.process_from_file nil
      end.to raise_error(ArgumentError)
    end

    it "should raise SlowLogFileNotPresent if file does not exist" do
      expect do
        subject.process_from_file "/tmp/1"
      end.to raise_error(described_class::SlowLogFileNotPresent)
    end

    it "should be able to process the entries" do
      expect(subject).to receive(:process_native_entry).exactly(12).times
      subject.process_from_file File.join(APP_PATH, "spec", "fixtures", "mysql_slow_log.log")
    end

    it "should be able to extract all required details" do
      received = nil
      expect(subject).to receive(:process_native_entry).exactly(12).times do |hash|
        next if received
        received  = hash
      end

      subject.process_from_file File.join(APP_PATH, "spec", "fixtures", "mysql_slow_log.log")

      received[:sql_text].should   == "SELECT * FROM salaries INNER JOIN `employees` ON `employees`.`emp_no` = `salaries`.`emp_no` WHERE employees.first_name LIKE '%g%' AND salaries.salary  >= 50 ORDER BY salaries.from_date ASC LIMIT 0,100;"
      received[:user_host].should  == "root[root] @  [192.168.27.2]"
      received[:query_time].should == 9.046720
      received[:lock_time].should  == 0.010155
      received[:rows_sent].should  == 100
      received[:rows_examined].should == 1347738
      received[:start_time].should == Time.at(1385012437)
      received[:server_id].should == 1
    end

    it "should be able to switch DB contexts" do
      received = []
      expect(subject).to receive(:process_native_entry).exactly(12).times do |hash|
        received << hash
      end

      subject.process_from_file File.join(APP_PATH, "spec", "fixtures", "mysql_slow_log.log")

      target_a = received[0..7].map { |h| h[:db] }
      target_a.uniq.should == ["employees"]
      received[8][:db].should == "employees_2"
      received[9][:db].should == "employees"
      received[10][:db].should == "employees"
      received[11][:db].should == "employees_2"
    end

  end

  describe "#process_native_entry" do

    let(:time_point_a) { Time.parse("11:10 PM") }
    let(:time_point_b) { Time.parse("9:13 PM") }
    let(:time_point_c) { Time.at(19) }

    let(:mysql_hash) do
      {
        sql_text: "SELECT * FROM `table`",
        query_time: time_point_a,
        lock_time:  time_point_b,
        user_host:  "funtimes[funtimes] @  [10.10.24.242]",
        start_time: time_point_c,
        rows_sent: 19,
        rows_examined: 23,
        db: "funtimes_production",
        last_insert_id: 25,
        insert_id: 69,
        server_id: 72,
      }
    end

    it "should pass a converted object into .process_slow_entry" do
      received = nil
      expect(subject).to receive(:process_slow_entry).once do |val|
        received = val
      end

      subject.process_native_entry(mysql_hash)

      received[:occurred_at].should == time_point_c
      received[:user].should == "funtimes"
      received[:host].should == "10.10.24.242"
      received[:rows_sent].should == 19
      received[:rows_examined].should == 23
      received[:schema].should == "funtimes_production"
      received[:last_insert_id].should == 25
      received[:insert_id].should == 69
      received[:server_id].should == 72
      received[:statement].should == "SELECT * FROM `table`"
      received[:execution_time].should == ((23 * 60 * 60) + (10 * 60)).to_f
      received[:lock_time].should == ((21 * 60 * 60) + (13 * 60)).to_f
    end

    it "should support Numeric query_time" do
      received = nil
      expect(subject).to receive(:process_slow_entry).once do |val|
        received = val
      end

      mod_hash = mysql_hash.merge(query_time: 23.93)
      subject.process_native_entry(mod_hash)

      received[:execution_time].should == 23.93
    end

    it "should support Numeric lock_time" do
      received = nil
      expect(subject).to receive(:process_slow_entry).once do |val|
        received = val
      end

      mod_hash = mysql_hash.merge(lock_time: 29.93)
      subject.process_native_entry(mod_hash)

      received[:lock_time].should == 29.93
    end

    it "should skip an entry if the entry is less than the most recent occurrence" do
      time_point = Time.at(19)
      expect(Poke::SystemModels::Query).to receive(:most_recent_statements) do 
        [time_point, []]
      end

      mod_hash = mysql_hash.merge(start_time: (time_point - 1.minute))

      expect(subject).to_not receive(:process_slow_entry)

      subject.process_native_entry mod_hash
    end

    it "should skip an entry if the timing is the same and statement is already known" do
      time_point = Time.at(19)
      expect(Poke::SystemModels::Query).to receive(:most_recent_statements) do 
        [time_point, ["t_4"]]
      end

      mod_hash = mysql_hash.merge(start_time: time_point, sql_text: "t_4")

      expect(subject).to_not receive(:process_slow_entry)

      subject.process_native_entry mod_hash
    end

    it "should not skip an entry if the timing is the same and statement is not already known" do
      time_point = Time.at(19)
      expect(Poke::SystemModels::Query).to receive(:most_recent_statements) do 
        [time_point, ["t_4"]]
      end

      mod_hash = mysql_hash.merge(start_time: time_point, sql_text: "t_3")

      received = nil
      expect(subject).to receive(:process_slow_entry).once do |val|
        received = val
      end

      subject.process_native_entry mod_hash

      received[:statement].should == "t_3"
    end

  end

end