require 'spec_helper'

describe Poke::Cli::Run do

  subject { described_class.new [] }

  it "should invoke BackgroundRunner" do
    expect(Poke::BackgroundRunner).to receive(:kickoff)

    subject.run
  end

end