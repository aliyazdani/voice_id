# VoiceId
  Wrapper around Microsoft Cognitive Services - Speaker Recognition API

## Installation
  ```
  $ gem install voice_id
  ```

## Examples
  
### create a new profile
```ruby
  identification = VoiceId::Identification.new("MS_speaker_recognition_api_key")
  profile = identification.create_profile
  # => { "identificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f" }
```
### create a new enrollment for a profile
```ruby
  profile_id = profile["identificationProfileId"]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio = true
  identification.create_enrollment(profile_id , short_audio, path_to_audio)
```
### identify a speaker
```ruby
  profile_ids = ["profile_id_1", "profile_id_2", ...]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio = true
  identification.identify_speaker(profile_ids, short_audio, path_to_audio)
```

## APIs
  Provides methods for two apis:

### Identification API
  Identify a person from a list of people - this is a text-independant api.
  Prior to being able to identify a speaker, a speaker (profile) must send a minimum
  of 30 seconds of recognizable audio.
  
### Verification API
  Verify that a person is who they say they are - this is a text-dependent api.
  Prior to being able to verify a speaker, a speaker (profile) must send three audio samples (from an API provided list) with their enrollment.


