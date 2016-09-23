module VoiceId
  class Identification < VoiceId::Base
    class ProfileIdsMissingError < StandardError; end

    # params
    #   operationId
    #     a valid url provided by calling #create_enrollment
    #     an operation's status is only available for 24 hours after creating enrollment
    #
    # Microsoft API response
    # 200 Response
    #   {
    #     "status"=>"succeeded", 
    #     "createdDateTime"=>"2016-09-20T01:51:39.134487Z", 
    #     "lastActionDateTime"=>"2016-09-20T01:51:41.4183611Z", 
    #     "processingResult"=>{
    #       "enrollmentStatus"=>"Enrolled", 
    #       "remainingEnrollmentSpeechTime"=>0.0, 
    #       "speechTime"=>7.93, # useful speech duration
    #       "enrollmentSpeechTime"=>31.72
    #      }
    #   }
    # 
    # 404 Response
    #   {
    #     "error":{
    #       "code" : "NotFound",
    #       "message" : "No operation id found", 
    #     }
    #   }
    #
    # returns
    #   success
    #     operation status { Hash }
    #   error
    #     false
    def get_operation_status(operationId)
      _method   = :Get
      _path     = "/operations/#{operationId}"
      _headers  = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? _response.parse : parse_error_response(_response)
    end

    # params
    #   profileIds - required
    #     a valid list of comma-separated values
    #   shortAudio
    #     set min audio length requirement to 1 sec 
    #     (still have to provide 30 secs(multiple enrollments))
    #   audio_file_path
    #     string representing location of wav file in system
    #
    # Microsoft API response
    # 202 Response
    #   operation url (can be checked by calling get_operation_status(operationId))
    #   (ex: "https://api.projectoxford.ai/spid/v1.0/operations/995a8745-0098-4c12-9889-bad14859y7a4")
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
    #     operation url { String }
    #   fail
    #     false
    def identify_speaker(profileIds, shortAudio, audio_file_path)
      if !profileIds.is_a?(Array) || profileIds.empty?
        raise ProfileIdsMissingError, "an array of profile ids is required"
      end

      _identificationProfileIds = profileIds.join(",")

      _method   = :Post
      _path     = "/identify?identificationProfileIds=#{_identificationProfileIds}&shortAudio=#{shortAudio}"
      _headers  = { } 
      _body     = create_body_for_enrollment(audio_file_path)
      _response = send_request(_path, _method, _headers, _body)

      _response.code == 202 ? _response.headers["Operation-Location"] : parse_error_response(_response)
    end

    # Microsoft API response
    # 200 Response 
    # {
    #   "identificationProfileId": "49a36324-fc4b-4387-aa06-090cfbf0064f",
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
      super("/identificationProfiles")
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
    #     true
    #   fail
    #     false (indicating delete of id failed)
    def delete_profile(profileId)
      super("/identificationProfiles/#{profileId}")
    end

    # Microsoft API response
    # 200 Response
    #   [
    #     {
    #       "identificationProfileId" : "111f427c-3791-468f-b709-fcef7660fff9",
    #       "locale" : "en-US",
    #       "enrollmentSpeechTime", 0.0
    #       "remainingEnrollmentSpeechTime" : 0.0,
    #       "createdDateTime" : "2015-04-23T18:25:43.511Z",
    #       "lastActionDateTime" : "2015-04-23T18:25:43.511Z",
    #       "enrollmentStatus" : "Enrolled" //[Enrolled | Enrolling | Training]
    #     }, 
    #   …]
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
      super('/identificationProfiles')
    end

    # params
    #   profileId
    #     a valid profileId { String }
    #
    # Microsoft API response
    # 200 Response
    #   {
    #     "identificationProfileId" : "111f427c-3791-468f-b709-fcef7660fff9",
    #     "locale" : "en-US",
    #     "enrollmentSpeechTime", 0.0
    #     "remainingEnrollmentSpeechTime" : 0.0,
    #     "createdDateTime" : "2015-04-23T18:25:43.511Z",
    #     "lastActionDateTime" : "2015-04-23T18:25:43.511Z",
    #     "enrollmentStatus" : "Enrolled" //[Enrolled | Enrolling | Training]
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
      super("/identificationProfiles/#{profileId}")
    end

    # params
    #   profileId
    #     a valid profileId { String }
    #   shortAudio
    #     false for default duration, true for any duration { Boolean }
    #   audio_file_path
    #     path to the audio file { String }
    #     audio requirments => Wav, PCM, 16k rate, 16 bit sample rate, mono
    #
    # Microsoft API response
    # 202 Response
    #   url to check the enrollment status
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
    #     a url { String }
    #   fail
    #     false
    def create_enrollment(profileId, shortAudio, audio_file_path)
      _method   = :Post
      _path     = "/identificationProfiles/#{profileId}/enroll"
      _headers  = { } 
      _body     = create_body_for_enrollment(audio_file_path)
      _response = send_request(_path, _method, _headers, _body)

      _response.code == 202 ? _response.headers["Operation-Location"] : parse_error_response(_response)
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
    #     true
    #   fail
    #     false (indicating delete of enrollments failed)
    def reset_all_enrollments_for_profile(profileId)
      super("/identificationProfiles/#{profileId}/reset")
    end
    
  end
end