$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'rr'
require 'ostruct'
require 'tmpdir'

ENV["MAX_PROCS"] = "1"
