require "rspec"
require "mimic"
require_relative "../lib/voice_id.rb"

require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end