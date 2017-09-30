#!/usr/bin/env ruby

require 'open-uri'
require 'inifile'

web_contents  = open('http://files.galacticexchange.io/boxes/version.txt').read

myini = IniFile.new(:content => web_contents)

version = myini['global']['version']

cmd =  'vagrant box add --force gex/base  http://files.galacticexchange.io/boxes/gex-' + version + '.box' 
puts cmd

system cmd





