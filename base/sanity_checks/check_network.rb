#!/usr/bin/env ruby

puts "Verifying your network configiration."

puts "**** Interfaces **** "

INTERFACES = `/sbin/ip addr`

puts INTERFACES

puts "**** Routes **** "

ROUTES = `/sbin/ip route`

puts ROUTES


puts "Checking for existence of the default route"

IP_ADDRESS = `/sbin/ip route | awk '/default/ { print $3 }'`

if IP_ADDRESS.length < 1
puts "Error: default route not set"
exit 3
end

 
pingResult = `ping -c 1 #{IP_ADDRESS}`

puts pingResult

if $?.exitstatus != 0
  puts "Error: Ping failed for the default gateway + #{IP_ADDRESS} "
  exit 6  
else 
  puts "Ping succeeded for the default gateway + #{IP_ADDRESS} "
end

puts "Pinging Google DNS server 8.8.8.8"

pingResult = `ping -c 1 8.8.8.8`

puts pingResult

if $?.exitstatus != 0
  puts "Error: cant ping 8.8.8.8. No connection to Internet"
  exit 4  
else 
  puts "Ping succeeded for Google DNS server 8.8.8.8"
end

puts "Pinging Galactic Exchange server api.galacticexchange.io"

pingResult = `ping -c 1 api.galacticexchange.io`

puts pingResult

if $?.exitstatus != 0
  puts "No connection to Galactic Exchange cloud"
  exit 5  
else 
  puts "Ping succeeded for api.galacticexchange.io"    
end

puts "Network configuration verified successfully"

exit 0
