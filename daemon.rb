#!/usr/bin/env ruby
# encoding: utf-8

STDOUT.sync = true
STDERR.sync = true

require 'bundler'
Bundler.require

require 'yaml'
require 'json'
require 'axlsx'
require 'mongoid'
require 'rufus-scheduler'

PushConf = YAML.load(File.read(File.join('./config/app.yml')))
puts PushConf
sleep
