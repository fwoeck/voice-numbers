#!/usr/bin/env ruby
# encoding: utf-8

STDOUT.sync = true
STDERR.sync = true
ENV['TZ']   = 'UTC'

require 'bundler'
Bundler.require

require 'yaml'
require 'json'

require './lib/numbers'
Numbers.setup

require './lib/call'
require './lib/user'
require './lib/agent'
require './lib/data_set'
require './lib/call_event'
require './lib/agent_event'
require './lib/generates_reports'
require './lib/aggregates_numbers'

require './lib/rrd_tool'
RrdTool.start

require './lib/amqp_manager'
AmqpManager.start

require './lib/scheduler'
Scheduler.start
