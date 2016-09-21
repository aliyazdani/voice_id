require_relative "spec_helper"

describe VoiceId::Identification do
  @identification_profile = {
    "identificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f",
  }

  enrollment_operation = { "Operation-Location" => "https://www.coolsite/operations/123456789" }

  @profile = {
    "identificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
    "locale" => "en-US",
    "enrollmentSpeechTime" => 0.0,
    "remainingEnrollmentSpeechTime" => 0.0,
    "createdDateTime" => "2015-04-23T18:25:43.511Z",
    "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
    "enrollmentStatus" => "Enrolled"
  }

  @profiles = [
    {
      "identificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
      "locale" => "en-US",
      "enrollmentSpeechTime" => 0.0,
      "remainingEnrollmentSpeechTime" => 0.0,
      "createdDateTime" => "2015-04-23T18:25:43.511Z",
      "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
      "enrollmentStatus" => "Enrolled"
    }
  ]

  json_type = { "content-type" => "application/json" }
  form_data_type = { "content-type" => "multipart/form-data"}

  Mimic.mimic do
    get("/identificationProfiles").returning(@profiles.to_json, 200, json_type)
    get("/identificationProfiles/:profileId").returning(@profile.to_json, 200, json_type)
    post("/identificationProfiles").returning(@identification_profile.to_json, 200, json_type)
    post("/identificationProfiles/:profileId/reset").returning("".to_json, 200, json_type)
    post("/identificationProfiles/:profileId/enroll").returning("".to_json, 202, json_type.merge(enrollment_operation))
    delete("/identificationProfiles/:profileId").returning("".to_json, 200, json_type)
  end

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
      expect(@identification.get_all_profiles).to eql(@profiles)
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
      allow(VoiceId::Identification).to receive(:create_body_for_enrollment).and_return(data)
      expect(@identification.create_enrollment(profileId , shortAudio, '/path/to/some/audio_file.wav')).to eql("https://www.coolsite/operations/123456789")
    end
  end

  describe "#reset_all_enrollments_for_profile" do
    it "should return true if all enrollments for a profile was deleted" do
      profileId = "0991883883"
      expect(@identification.reset_all_enrollments_for_profile(profileId)).to eql(true)
    end
  end
end