#!/usr/bin/env ruby
# encoding: utf-8

STDOUT.sync = true
STDERR.sync = true

require 'bundler'
Bundler.require

require 'yaml'
require 'json'


Signal.trap('TERM') do
  puts 'Shutting down..'
  sleep 1 while RS.running_jobs.size > 0
  puts 'Numbers finished..'
  exit
end


require './lib/numbers'
Numbers.setup

require './lib/user'
require './lib/ami_event'
require './lib/generates_reports'
require './lib/aggregates_numbers'

require './lib/amqp_manager'
AmqpManager.start


RS = Rufus::Scheduler.new
RS.cron '* * * * *', overlap: false do
  GeneratesReports.new(
    AggregatesNumbers.new Numbers.set_timestamp
  ).log
end


puts 'Numbers launched..'
RS.join
