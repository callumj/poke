require 'spec_helper'

describe Poke::SystemModels::ExecutionEvent do

  it "should be able to find .by_name" do
    subject = described_class.create name: "crash"
    subject2 = described_class.create name: "crashe"
    described_class.by_name("crash").to_a.should == [subject]
    described_class.by_name("crashe").to_a.should == [subject2]
  end

  it "should enforce PK" do
    subject = described_class.create name: "crash"
    expect do
      described_class.create name: "crash"
    end.to raise_error(Sequel::DatabaseError)
  end

  it "should require a name" do
    subject = described_class.new
    subject.name.should be_nil

    subject.should_not be_valid
    subject.errors.keys.should include :name
  end

  it "should set a hash on save" do
    subject = described_class.new name: "thingo"
    expect(CityHash).to receive(:hash64).with("thingo") { 1975 }

    subject.save
    subject.name_hash.should == 1975
  end

  describe ".conditionally_create" do

    it "should create" do
      described_class.by_name("crash").should be_empty
      res = nil
      expect do
        res = described_class.conditionally_create("crash")
      end.to change { described_class.by_name("crash").count }.from(0).to(1)

      res.name.should == "crash"
    end

    it "should find existing" do
      subject = described_class.create name: "crash"
      res = nil
      expect do
        res = described_class.conditionally_create("crash")
      end.to_not change { described_class.by_name("crash").count }.from(1)

      res.should == subject
    end

  end

end
