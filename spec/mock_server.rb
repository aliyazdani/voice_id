json_type = { "content-type" => "application/json" }
form_data_type = { "content-type" => "multipart/form-data"}
enrollment_operation = { "Operation-Location" => "https://www.coolsite/operations/123456789" }

@new_identification_profile = {
  "identificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f",
}

@identification_profile = {
  "identificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
  "locale" => "en-US",
  "enrollmentSpeechTime" => 0.0,
  "remainingEnrollmentSpeechTime" => 0.0,
  "createdDateTime" => "2015-04-23T18:25:43.511Z",
  "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
  "enrollmentStatus" => "Enrolled"
}

@identification_profiles = [
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

@new_verification_profile = {
  "verificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f",
}

@verification_profiles = [
  {
    "verificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
    "locale" => "en-US",
    "enrollmentsCount" => 2,
    "remainingEnrollmentsCount" => 0,
    "createdDateTime" => "2015-04-23T18:25:43.511Z", 
    "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
    "enrollmentStatus" => "Enrolled"
  }
]

@verification_profile = {
  "verificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
  "locale" => "en-US",
  "enrollmentsCount" => 2,
  "remainingEnrollmentsCount" => 0,
  "createdDateTime" => "2015-04-23T18:25:43.511Z", 
  "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
  "enrollmentStatus" => "Enrolled"
}

Mimic.mimic do
  get("/identificationProfiles").returning(@identification_profiles.to_json, 200, json_type)
  get("/identificationProfiles/:profileId").returning(@identification_profile.to_json, 200, json_type)
  post("/identificationProfiles").returning(@new_identification_profile.to_json, 200, json_type)
  post("/identificationProfiles/:profileId/reset").returning("".to_json, 200, json_type)
  post("/identificationProfiles/:profileId/enroll").returning("".to_json, 202, json_type.merge(enrollment_operation))
  delete("/identificationProfiles/:profileId").returning("".to_json, 200, json_type)

  get("/verificationProfiles").returning(@verification_profiles.to_json, 200, json_type)
  get("/verificationProfiles/:profileId").returning(@verification_profile.to_json, 200, json_type)
  post("/verificationProfiles").returning(@new_verification_profile.to_json, 200, json_type)
  post("/verificationProfiles/:profileId/reset").returning("".to_json, 200, json_type)
  post("/verificationProfiles/:profileId/enroll").returning("".to_json, 200, json_type.merge(enrollment_operation))
  delete("/verificationProfiles/:profileId").returning("".to_json, 200, json_type)
end