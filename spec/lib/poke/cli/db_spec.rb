require 'spec_helper'

describe Poke::Cli::Db do

  context "init action" do

    it "should run init when instructed" do
      sub = described_class.new ["init"]
      expect(Poke::Utils::DbManagement).to receive(:init_system_db).with(false)

      sub.run
    end

    it "should send true for recreate" do
      sub = described_class.new ["init", "recreate:true"]
      expect(Poke::Utils::DbManagement).to receive(:init_system_db).with(true)

      sub.run
    end

  end

end