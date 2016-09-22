require 'http'

module VoiceId
  module RequestHelpers

    # generate body for content-type "multipart/form-data"
    def create_body_for_enrollment(audio_file_path)
      { :form => { :file   => HTTP::FormData::File.new(audio_file_path) } }
    end

    def send_request(path, method, req_headers, body)
      _headers =  req_headers ? headers.merge(req_headers) : headers
      _path = api_base_url + path
      _req = HTTP.headers(_headers)

      case method
      when :Post
        body ? _req.post(_path, body) : _req.post(_path)
      when :Get
        _req.get(_path)
      when :Delete
        _req.delete(_path)
      end
    end

  end
end