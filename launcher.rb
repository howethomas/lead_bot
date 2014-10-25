#!/usr/bin/env ruby
require 'pry'
require File.expand_path('../lib/script_conversation', __FILE__)

conversation do
  url = "http://localhost:3000/plugin/simpler_script.rb"
  require 'open-uri'
  code_from_url = open(url) {|f| f.read }
  eval(code_from_url)
end
