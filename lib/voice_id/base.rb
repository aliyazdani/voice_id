module VoiceId
  class Base
    include RequestHelpers
    include Utils

    attr_accessor :api_base_url, :api_key, :api_version, :headers, :use_ssl
    def initialize(api_key)
      @api_version  = "v1.0"
      @api_key      = api_key
      @use_ssl      = true
      @api_base_url = "https://api.projectoxford.ai/spid/#{@api_version}"
      @headers      = { "Ocp-Apim-Subscription-Key" => api_key }
    end

    def create_profile(path)
      _method   = :Post
      _path     = path
      _headers  = { "Content-Type" => "application/json" }
      _body     = { :json => { :locale   => "en-us" } }
      _response = send_request(_path, _method, _headers, _body)
      
      _response.code == 200 ? _response.parse : parse_error_response(_response)
    end

    # No MIME returned from API (can't parse so we return 'true')
    def delete_profile(path)
      _method   = :Delete
      _path     = path
      _headers  = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? true : parse_error_response(_response)
    end

    def get_all_profiles(path)
      _method   = :Get
      _path     = path
      _headers  = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? _response.parse : parse_error_response(_response)
    end

    def get_profile(path)
      _method   = :Get
      _path     = path
      _headers  = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? _response.parse : parse_error_response(_response)
    end

    # No MIME returned from API (can't parse so we return 'true')
    def reset_all_enrollments_for_profile(path)
      _method   = :Post
      _path     = path
      _headers  = { "Content-Type" => "application/json" }
      _response = send_request(_path, _method, _headers, nil)

      _response.code == 200 ? true : parse_error_response(_response)
    end
  end
end