require 'spec_helper'

describe command("whoami") do
  it "debug" do
    expect(subject.stdout).to match(/root/)
  end
end
