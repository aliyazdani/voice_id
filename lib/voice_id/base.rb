require 'pry'

module VoiceId
  class Base
    include RequestHelpers

    attr_accessor :api_base_url, :api_key, :api_version, :headers, :use_ssl
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
    #   success
    #     operation status { Hash }
    #   error
    #     false
    def get_operation_status(operationId)
      _method = :Get
      _path = "/operations/#{operationId}"
      _headers = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? _response.parse : false
    end

    def create_profile(path)
      _method  = :Post
      _path    = path
      _headers = { "Content-Type" => "application/json" }
      _body    = { :json => { :locale   => "en-us" } }
      _response = send_request(_path, _method, _headers, _body)

      _response.code == 200 ? _response.parse : false
    end

    def delete_profile(path)
      _method  = :Delete
      _path    = path
      _headers = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200
    end

    def get_all_profiles(path)
      _method  = :Get
      _path    = path
      _headers = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? _response.parse : false
    end

    def get_profile(path)
      _method  = :Get
      _path    = path
      _headers = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? _response.parse : false
    end

    def reset_all_enrollments_for_profile(path)
      _method  = :Post
      _path    = path
      _headers = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200
    end
  end
end