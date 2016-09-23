require_relative "spec_helper"

describe VoiceId::Identification do

  @profile = {
    "identificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
    "locale" => "en-US",
    "enrollmentSpeechTime" => 0.0,
    "remainingEnrollmentSpeechTime" => 0.0,
    "createdDateTime" => "2015-04-23T18:25:43.511Z",
    "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
    "enrollmentStatus" => "Enrolled"
  }

  before :each do
    @identification = VoiceId::Identification.new("some_api_key")
    @identification.api_base_url = "http://localhost:11988"
  end


  describe "#create_profile" do
    it "should be able to create a new profile and return the details" do
      expect(@identification.create_profile).to eql(@identification_profile)
    end
  end

  describe "#delete_profile" do
    it "should delete a profile and return true" do
      profileId = "12345678"        
      expect(@identification.delete_profile(profileId)).to eql(true)
    end
  end

  describe "#get_all_profiles" do
    it "should return an array of all profiles" do
      expect(@identification.get_all_profiles).to eql(@identification_profiles)
    end
  end

  describe "#get_profile" do
    it "should return a profile hash" do
      profileId = "987654321"
      expect(@identification.get_profile(profileId)).to eql(@profile)
    end
  end

  describe "#create_enrollment" do
    it "should create a new enrollment for a profile and return an operation url" do
      data       = { :form => { :file   => "cool.wav" } }
      profileId  = "0991883883"
      shortAudio = true
      allow_any_instance_of(VoiceId::RequestHelpers).to receive(:create_body_for_enrollment).and_return(data)
      expect(@identification.create_enrollment(profileId , shortAudio, '/path/to/some/audio_file.wav')).to eql("https://www.coolsite/operations/123456789")
    end
  end

  describe "#reset_all_enrollments_for_profile" do
    it "should return true if all enrollments for a profile was deleted" do
      profileId = "0991883883"
      expect(@identification.reset_all_enrollments_for_profile(profileId)).to eql(true)
    end
  end

  describe "#get_operation_id" do
    it "returns an operation id" do
      operation_url = "https://api.projectoxford.ai/spid/v1.0/operations/995a8745-0098-4c12-9889-bad14859y7a4"
      expect(@identification.get_operation_id(operation_url)).to eql("995a8745-0098-4c12-9889-bad14859y7a4")
    end
  end

  describe "#identify_speaker" do
    it "identifies a speaker using any audio snippet" do
      data = { :form => { :file   => "cool.wav" } }
      profile_ids = ["profile_id1", "profile_id2"]
      short_audio = true
      audio_file_path = '/path/to/some/audio_file.wav'
      allow_any_instance_of(VoiceId::RequestHelpers).to receive(:create_body_for_enrollment).and_return(data)
      expect(@identification.identify_speaker(profile_ids, short_audio, audio_file_path)).to eql("https://www.coolsite/operations/123456789")
    end
  end

  describe "#get_operation_status(operationId)" do
    it "returns operation status" do
      operation_id = "1234567890"
      expect(@identification.get_operation_status(operation_id)).to eql(@operation_status)
    end
  end
end