require 'spec_helper'

describe command("whoami") do
  it "debug" do
    expect(subject.stdout).to match(/root/)
  end
end

# describe port(8080) do
#   it { should be_listening }
# end

# describe 'ports' do
#   it 'ports listening' do
#     ports = [8030, 8088, 8042, 8040, 8033]
#     cmd = "netcat -z -v localhost 1-50000"
#     output = command(cmd).stdout
#
#     ports.each do |port|
#       expect(output).to match /\s+#{port}\s+/
#     end
#   end
# end

# describe command("java -version 2>&1") do
#   it "java version" do
#     expect(subject.stdout).to match(/1.7./)
#   end
# end

# describe port(80) do
#   it { should be_listening }
# end
