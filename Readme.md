# VoiceId
  Wrapper around Microsoft Cognitive Services - Speaker Recognition API

## Installation
  ```
  $ gem install voice_id
  ```

## Examples
  
### Create a new profile
```ruby
  identification = VoiceId::Identification.new("MS_speaker_recognition_api_key")
  profile = identification.create_profile
  # => { "identificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f" }
```
### Create a new enrollment for a profile
```ruby
  profile_id = profile["identificationProfileId"]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio = true
  identification.create_enrollment(profile_id , short_audio, path_to_audio)
```
### Identify a speaker
```ruby
  profile_ids = ["profile_id_1", "profile_id_2", ...]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio = true
  identification.identify_speaker(profile_ids, short_audio, path_to_audio)
```

## APIs
  Provides methods for two APIs:

### Identification API
  Identify a person from a list of people - this is a text-independant api.
  Prior to being able to identify a speaker, a speaker (profile) must send a minimum
  of 30 seconds of recognizable audio.
#### Create a new profile
`create_profile` Each person needs a unique profile
```ruby
  identification = VoiceId::Identification.new("MS_speaker_recognition_api_key")
  profile = identification.create_profile
  # => { "identificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f" }
```
#### Create an enrollment for a profile
`create_enrollment(profile_id, short_audio, audio_file_path)` An enrollment is how audio samples
are associated with a profile (training the service).  For the Identification API a minimum of 30 seconds
of recognizable speach is required.  This can be done through multiple enrollments.
`Valid Audio Format
Container WAV
Encoding  PCM
Rate  16K
Sample Format 16 bit
Channels  Mono
`
```ruby
  profile_id = "1234567890"
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio = true # true - set minimum duration to 1 sec (5 sec by default per enrollment)
  identification.create_enrollment(profile_id, short_audio, path_to_audio)
  # returns an operation url that you can use to check the status of the enrollment
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B5"
```

### Verification API
  Verify that a person is who they say they are - this is a text-dependent api.
  Prior to being able to verify a speaker, a speaker (profile) must send three audio samples (from an API provided list) with their enrollment.


