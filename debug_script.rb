#! /usr/bin/env ruby 

def run(cmd)
  puts "run**** #{cmd}"
  res = `#{cmd}`
  puts "#{res}"
end

run('cd rabbit && git add . && git commit -m "debug" && git push origin master')

run 'ssh gex@51.1.0.50 "cd /disk2/vagrant/rabbit && (git pull origin master || true ) '
run 'ssh gex@51.1.0.50 "cd /disk2/vagrant/rabbit && vagrant provision dev --provision-with=fixes"'
