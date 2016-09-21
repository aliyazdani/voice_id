require 'http'

module VoiceId
  module RequestHelpers

    def send_request(path, method, req_headers, body)
      _headers =  req_headers ? headers.merge(req_headers) : headers
      _path = @api_base_url + path
      _req = HTTP.headers(_headers)

      case method
      when :Post
        if _headers["Content-Type"] == "application/json"
          body ? _req.post(_path, body) : _req.post(_path)
        else
          _req.post(_path, body)
        end
      when :Get
        _req.get(_path)
      when :Delete
        _req.delete(_path)
      end
    end

  end
end