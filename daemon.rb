#!/usr/bin/env ruby
# encoding: utf-8

STDOUT.sync = true
STDERR.sync = true
ENV['TZ']   = 'UTC'

require 'bundler'
Bundler.require

require 'yaml'
require 'json'


Signal.trap('TERM') do
  puts "#{Time.now.utc} :: Shutting down.."
  sleep 1 while RS.running_jobs.size > 0
  puts "#{Time.now.utc} :: Numbers finished.."
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


puts "#{Time.now.utc} :: Numbers launched.."
begin
  RS.join
rescue ThreadError
  # see https://github.com/jmettraux/rufus-scheduler/issues/98
end
