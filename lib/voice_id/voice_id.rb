#--
# Copyright (c) 2016- Ali Yazdani <aliyazdani82@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'net/http'
require 'net/http/post/multipart'
require 'http'
require 'json'
require 'pry'

require_relative 'request_helpers'

class VoiceId
  include RequestHelpers

  attr_reader :api_base_url, :api_key, :api_version, :headers, :use_ssl
  def initialize(api_key)
    @api_version  = "v1.0"
    @api_key      = api_key
    @use_ssl      = true
    @api_base_url = "https://api.projectoxford.ai/spid/#{@api_version}"
    @headers      = { "Ocp-Apim-Subscription-Key" => api_key }
  end

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
  #   200 - success
  #     operation status { Hash }
  #   404 - error
  #     false
  def get_operation_status(operationId)
    _method = :Get
    _path = "/operations/#{operationId}"
    _headers = { "Content-Type" => "application/json" }
    response = send_request(_path, _method, _headers, nil)

    response.code == 200 ? response.parse : false
  end

  def create_profile(path)
    _method  = :Post
    _path    = path
    _headers = { "Content-Type" => "application/json" }
    _body    = { :json => { :locale   => "en-us" } }
    response = send_request(_path, _method, _headers, _body)

    response.code == 200 ? response.parse : false
  end

  def delete_profile(path)
    _method  = :Delete
    _path    = path
    _headers = { "Content-Type" => "application/json" }
    response = send_request(_path, _method, _headers, nil)

    response.code == 200
  end

  def get_all_profiles(path)
    _method  = :Get
    _path    = path
    _headers = { "Content-Type" => "application/json" }
    response = send_request(_path, _method, _headers, nil)

    response.code == 200 ? response.parse : false
  end

  def get_profile(path)
    _method  = :Get
    _path    = path
    _headers = { "Content-Type" => "application/json" }
    response = send_request(_path, _method, _headers, nil)

    response.code == 200 ? response.parse : false
  end

  def reset_all_enrollments_for_profile(path)
    _method  = :Post
    _path    = path
    _headers = { "Content-Type" => "application/json" }
    response = send_request(_path, _method, _headers, nil)

    response.code == 200
  end

  # use this class to identify a user from a group
  class Identification < VoiceId
    class ProfileIdsMissingError < StandardError; end

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
      unless profileIds.is_a?(Array) && !profileIds.empty?
        raise ProfileIdsMissingError, "an array of profile ids is required"
      end

      _identificationProfileIds = profileIds.join(",")
      _method = :Post
      _path      = "/identify?identificationProfileIds=#{_identificationProfileIds}&shortAudio=#{shortAudio}"
      _headers = { } 
      _body = { :form => { :file   => HTTP::FormData::File.new(audio_file_path) } }

      response = send_request(_path, _method, _headers, _body)

      response.code == 202 ? response.headers["Operation-Location"] : false
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
    #   200 - success
    #     new profileId { Hash }
    #   500 - error
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
    #   200 - success
    #     profile id that was deleted { String }
    #   500 - error
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
    #   200 - success
    #     A list of all the profiles { Array }
    #   500 - error
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
    #   200 - success
    #     a profile { Hash }
    #   500 - error
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
    #   202 - success
    #     a url { String }
    #   500 - error
    #     false
    def create_enrollment(profileId, shortAudio, audio_file_path)
      _method = :Post
      _path          = "/identificationProfiles/#{profileId}/enroll"
      _headers = { } 
      _body = { :form => { :file   => HTTP::FormData::File.new(audio_file_path) } }

      response = send_request(_path, _method, _headers, _body)

      response.code == 202 ? response.headers["Operation-Location"] : false
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
      super("/identificationProfiles/#{profileId}/reset")
    end

  end

  class Verification < VoiceId

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
