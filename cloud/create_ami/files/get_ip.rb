#!/usr/bin/env ruby

COUNTER_PATH = '/home/vagrant/counter'

def get_ip(index)
  '10.175.' + ((2 * index)/256).to_s + "." + ((2 * index) % 256).to_s
end


File.open(COUNTER_PATH, "r+") do |file|

  file.flock(File::LOCK_EX)
  index = file.readline.strip.to_i

  client_ip = get_ip(index)

  puts client_ip

  index = index + 1
  file.rewind
  file.write(index)
  file.flush
  file.truncate(file.pos)

end
