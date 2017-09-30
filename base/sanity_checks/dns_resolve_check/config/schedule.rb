#!/usr/bin/env ruby

every 5.minutes do
  rake 'update_hosts'
end