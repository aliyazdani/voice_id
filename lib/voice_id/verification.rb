module VoiceId
  class Verification < VoiceId::Base

    # params
    #   profile_id
    #     unique profile id
    #   audio_file_path
    #     path to the audio of speaker
    #
    # Microsoft API response
    # 200 Response 
    # {
    #   "result" : "Accept", // [Accept | Reject]
    #   "confidence" : "Normal", // [Low | Normal | High]
    #   "phrase": "recognized phrase"
    # }
    #
    #
    # returns
    #   success
    #     verification results { Hash }
    #   fail (500 error)
    #     false
    def verify_speaker(profile_id, audio_file_path)
        _method   = :Post
        _path     = "/verify?verificationProfileId=#{profile_id}"
        _headers  = { } 
        _body     = create_body_for_enrollment(audio_file_path)
        _response = send_request(_path, _method, _headers, _body)

        _response.code == 200 ? _response.parse : false
    end

    # Microsoft API response
    # 200 Response 
    # {
    #   "verificationProfileId": "49a36324-fc4b-4387-aa06-090cfbf0064f",
    # }
    #
    # 500 Response
    # {
    #   "error":{
    #     "code" : "InternalServerError",
    #     "message" : "SpeakerInvalid",
    #   }
    # }
    #
    # returns
    #   success
    #     new profileId { Hash }
    #   fail
    #     false (indicating new profile was not created)
    def create_profile
      super("/verificationProfiles")
    end

    # params
    #   profileId - required
    #     a valid id { String }
    #
    # Microsoft API response
    # 200 Response
    # "" (empty string)
    # 
    # 500 Response
    #    {
    #      "error": {
    #        "code" : "InternalServerError",
    #        "message" : "SpeakerInvalid", 
    #      }
    #   }
    #
    # returns
    #   success
    #     profile id that was deleted { String }
    #   fail
    #     false (indicating delete of id failed)
    def delete_profile(profileId)
      super("/verificationProfiles/#{profileId}")
    end

    # Microsoft API response
    # 200 Response
    #   [{
    #     "verificationProfileId" : "111f427c-3791-468f-b709-fcef7660fff9",
    #     "locale" : "en-US",
    #     "enrollmentsCount" : 2,
    #     "remainingEnrollmentsCount" : 0,
    #     "createdDateTime" : "2015-04-23T18:25:43.511Z", 
    #     "lastActionDateTime" : "2015-04-23T18:25:43.511Z",
    #     "enrollmentStatus" : "Enrolled" //[Enrolled | Enrolling | Training]
    #   }, …]
    # 
    # 500 Response
    #    {
    #      "error": {
    #        "code" : "InternalServerError",
    #        "message" : "SpeakerInvalid", 
    #      }
    #   }
    #
    # returns
    #   success
    #     A list of all the profiles { Array }
    #   fail
    #     false (indicating delete of id failed)
    def get_all_profiles
      super('/verificationProfiles')
    end

    # params
    #   profileId
    #     a valid profileId { String }
    #
    # Microsoft API response
    # 200 Response
    #   {
    #     "verificationProfileId" : "111f427c-3791-468f-b709-fcef7660fff9",
    #     "locale" : "en-US",
    #     "enrollmentsCount" : 2,
    #     "remainingEnrollmentsCount" : 0,
    #     "createdDateTime" : "2015-04-23T18:25:43.511Z", 
    #     "lastActionDateTime" : "2015-04-23T18:25:43.511Z",
    #     "enrollmentStatus" : "Enrolled" // [Enrolled | Enrolling | Training]
    #   }
    # 
    # 500 Response
    #    {
    #      "error": {
    #        "code" : "InternalServerError",
    #        "message" : "SpeakerInvalid", 
    #      }
    #   }
    #
    # returns
    #   success
    #     a profile { Hash }
    #   fail
    #     false (indicating delete of id failed)
    def get_profile(profileId)
      super("/verificationProfiles/#{profileId}")
    end

    # each speaker(profile) must provide at least 3 enrollments to the api
    # params
    #   profileId
    #     a valid profileId { String }
    #   audio_file_path
    #     path to the audio file { String }
    #     audio requirments => Wav, PCM, 16k rate, 16 bit sample rate, mono
    #
    # Microsoft API response
    # 200 Response
    #   {
    #     "enrollmentStatus" : "Enrolled", // [Enrolled | Enrolling | Training]
    #     "enrollmentsCount":0,
    #     "remainingEnrollments" : 0,
    #     "phrase" : "Recognized verification phrase"
    #   }
    # 
    # 500 Response
    #    {
    #      "error": {
    #        "code" : "InternalServerError",
    #        "message" : "SpeakerInvalid", 
    #      }
    #   }
    #
    # returns
    #   success
    #     enrollment details { Hash }
    #   fail
    #     false
    def create_enrollment(profileId, audio_file_path)
      _method   = :Post
      _path     = "/verificationProfiles/#{profileId}/enroll"
      _headers  = { } 
      _body     = create_body_for_enrollment(audio_file_path)
      _response = send_request(_path, _method, _headers, _body)

      _response.code == 200 ? _response.parse : false
    end

    # params
    #   profileId - required
    #     a valid id { String }
    #
    # Microsoft API response
    # 200 Response
    # "" (empty string)
    # 
    # 500 Response
    #    {
    #      "error": {
    #        "code" : "InternalServerError",
    #        "message" : "SpeakerInvalid", 
    #      }
    #   }
    #
    # returns
    #   success
    #     profile id that was deleted { String }
    #   fail
    #     false (indicating delete of enrollments failed)
    def reset_all_enrollments_for_profile(profileId)
      super("/verificationProfiles/#{profileId}/reset")
    end

    # params
    #   locale - required
    #     a valid query string (used to return phrases in selected language)
    #
    # Microsoft API response
    # 200 Response
    #  [
    #   {"phrase"=>"i am going to make him an offer he cannot refuse"}, 
    #   {"phrase"=>"houston we have had a problem"}, 
    #   {"phrase"=>"my voice is my passport verify me"}, 
    #   {"phrase"=>"apple juice tastes funny after toothpaste"}, 
    #   {"phrase"=>"you can get in without your password"}, 
    #   {"phrase"=>"you can activate security system now"}, 
    #   {"phrase"=>"my voice is stronger than passwords"}, 
    #   {"phrase"=>"my password is not your business"}, 
    #   {"phrase"=>"my name is unknown to you"}, 
    #   {"phrase"=>"be yourself everyone else is already taken"}
    # ]
    # 
    # 500 Response
    #    {
    #      "error": {
    #        "code" : "InternalServerError",
    #        "message" : "SpeakerInvalid", 
    #      }
    #   }
    #
    # returns
    #   success
    #     list of acceptable phrases { Array }
    #   fail
    #     false
    def list_all_verification_phrases
      _method   = :Get
      _locale   = "en-us"
      _path     = "/verificationPhrases?locale=#{_locale}"
      _headers  = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? _response.parse : false
    end
  end
end