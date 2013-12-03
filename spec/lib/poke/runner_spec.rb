require 'spec_helper'

describe Poke::Runners do

  it "should not return a runner if no target DB is configured" do
    expect(Poke).to receive(:target_db) do
      nil
    end

    described_class.runner.should be_nil
  end

  it "should return the MySQL runner class if the target DB scheme is MySQL" do
    db = Object.new
    expect(db).to receive(:adapter_scheme) do
      :mysql
    end

    expect(Poke).to receive(:target_db).twice do
      db
    end

    described_class.runner.should == Poke::Runners::Mysql
  end

  it "should return the MySQL runner class if the target DB scheme is a MySQL variant" do
    db = Object.new
    expect(db).to receive(:adapter_scheme) do
      :mysql2
    end

    expect(Poke).to receive(:target_db).twice do
      db
    end

    described_class.runner.should == Poke::Runners::Mysql
  end

  it "should return nothing if the scheme is not known" do
    db = Object.new
    expect(db).to receive(:adapter_scheme) do
      :mongodb
    end

    expect(Poke).to receive(:target_db).twice do
      db
    end

    described_class.runner.should be_nil
  end

end