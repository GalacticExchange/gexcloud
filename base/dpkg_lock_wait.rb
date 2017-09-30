
i = 0
while system('fuser /var/lib/dpkg/lock') do

  puts "Apt lock wait #{Time.now}"

  raise 'Cannot wait for dpkg lock' if i > 480

  i = i + 1
  sleep 30

end