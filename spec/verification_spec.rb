require_relative "spec_helper"

describe VoiceId::Verification do

  before :each do
    @verification = VoiceId::Verification.new("some_api_key")
    @verification.api_base_url = "http://localhost:11988"
  end

  describe "#create_profile" do
    it "should be able to create a new profile and return the details" do
      expect(@verification.create_profile).to eql(@new_verification_profile)
    end
  end

  describe "#delete_profile" do
    it "should delete a profile and return true" do
      profileId = "12345678"        
      expect(@verification.delete_profile(profileId)).to eql(true)
    end
  end

  describe "#get_all_profiles" do
    it "should return an array of all profiles" do
      expect(@verification.get_all_profiles).to eql(@verification_profiles)
    end
  end

  describe "#get_profile" do
    it "should return a profile hash" do
      profileId = "987654321"
      expect(@verification.get_profile(profileId)).to eql(@verification_profile)
    end
  end

  describe "#create_enrollment" do
    it "should create a new enrollment for a profile and return an operation url" do
      data       = { :form => { :file   => "cool.wav" } }
      profileId  = "0991883883"
      allow_any_instance_of(VoiceId::RequestHelpers).to receive(:create_body_for_enrollment).and_return(data)
      expect(@verification.create_enrollment(profileId, '/path/to/some/audio_file.wav')).to eql("https://www.coolsite/operations/123456789")
    end
  end

  describe "#reset_all_enrollments_for_profile" do
    it "should return true if all enrollments for a profile was deleted" do
      profileId = "0991883883"
      expect(@verification.reset_all_enrollments_for_profile(profileId)).to eql(true)
    end
  end

  describe "#get_operation_id" do
    it "returns an operation id" do
      operation_url = "https://api.projectoxford.ai/spid/v1.0/operations/995a8745-0098-4c12-9889-bad14859y7a4"
      expect(@verification.get_operation_id(operation_url)).to eql("995a8745-0098-4c12-9889-bad14859y7a4")
    end
  end
end