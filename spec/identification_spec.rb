require "rspec"
require_relative "spec_helper"
require_relative "../lib/voice_id.rb"

describe VoiceId::Identification do
  before :each do
    # @identification = VoiceId::Identification.new("")
    # @identification.stub(:create_profile)
  end
  context '#create_profile' do
    it "should be able to create a new profile" do
      Mimic.mimic.post("/identificationProfiles/").returning("hello world")
      @identification = VoiceId::Identification.new("")
      response = @identification.create_profile
      puts response
    end
  end
end