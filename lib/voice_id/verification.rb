module VoiceId
  class Verification < VoiceId::Base

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
    #   200 - success
    #     new profileId { Hash }
    #   500 - error
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
    #   200 - success
    #     profile id that was deleted { String }
    #   500 - error
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
    #   200 - success
    #     A list of all the profiles { Array }
    #   500 - error
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
    #   200 - success
    #     a profile { Hash }
    #   500 - error
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
    #   error
    #     false
    def create_enrollment(profileId, audio_file_path)
      path          = "/verificationProfiles/#{profileId}/enroll"
      method        = :Post
      headers       = { "Content-Type" => "multipart/form-data" }
      uri           = generate_uri(path)
      multipart     = true

      generate_request(method, uri, headers, multipart, audio_file_path) do |request|
        response = send_request(uri, request)
        puts response.body
        # api returns url of enrollment status in response headers
        response.code == '200' ? JSON.parse(response.body) : false
      end


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
    #   200 - success
    #     profile id that was deleted { String }
    #   500 - error
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
    #   error
    #     false
    def list_all_verification_phrases
      _method  = :Get
      _locale  = "en-us"
      _path    = "/verificationPhrases?locale=#{_locale}"
      _headers = { "Content-Type" => "application/json" }
      response = send_request(_path, _method, _headers, nil)

      response.code == 200 ? response.parse : false
    end
  end
end