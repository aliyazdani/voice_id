require_relative '../voice_id'
identification = VoiceId::Identification.new("cf0f820a992f4b0fa4ec9c1c48b37151")
profile        = identification.create_profile
profile_id    = profile["identificationProfileId"]
short_audio   = true
path_to_audio = "/Users/aliyazdani/Downloads/unhappy_converted.wav"
operation_url = identification.create_enrollment(profile_id , short_audio, path_to_audio)
p operation_url