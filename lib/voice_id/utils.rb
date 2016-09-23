module VoiceId
  module Utils
    def get_operation_id(operation_url)
      operation_url.match(/operations\/(.+)/)[1]
    end
  end
end