require 'spec_helper'

describe Poke::Cli::Run do

  subject { described_class.new [] }

  it "should invoke BackgroundRunner and Web" do
    expect(Poke::BackgroundRunner).to receive(:kickoff)
    expect(Poke::Web::Core).to receive(:run!)

    subject.run
  end

end