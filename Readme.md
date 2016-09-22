# VoiceId
  Wrapper around Microsoft Cognitive Services - Speaker Recognition API

## Installation
  sign up and pick up a new api key (speaker recognition API key) 
  [https://www.microsoft.com/cognitive-services](https://www.microsoft.com/cognitive-services)

  ```
  $ gem install voice_id
  ```

## Examples
  
### Create a new profile
```ruby
  identification = VoiceId::Identification.new("MS_speaker_recognition_api_key")
  profile        = identification.create_profile
  # => { "identificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f" }
```
### Create a new enrollment for a profile
```ruby
  profile_id    = profile["identificationProfileId"]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio   = true
  identification.create_enrollment(profile_id , short_audio, path_to_audio)
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B5"
```
### Identify a speaker
```ruby
  profile_ids   = ["profile_id_1", "profile_id_2", ...]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio   = true
  operation     = identification.identify_speaker(profile_ids, short_audio, path_to_audio)
  # => "https://api.projectoxford.ai/spid/v1.0/operations/995a8745-0098-4c12-9889-bad14859y7a4"
```
### Check to see the results of speaker identification (above)
```ruby
  identification.get_operation_status(operationId)
  # =>     

```

## APIs
  Provides methods for two APIs:

### Identification API
Identify a person from a list of people - this is a text-independant api.
Prior to being able to identify a speaker, a speaker (profile) must send a minimum
of 30 seconds of recognizable audio.
```
identification = VoiceId::Identification.new("MS_speaker_recognition_api_key")
```

#### create_profile
Each person needs a unique profile, this creates a new one.
```ruby
  profile = identification.create_profile
  # => { "identificationProfileId" => "49a36324-fc4b-4387-aa06-090cfbf0064f" }
```

#### create_enrollment(profile_id, short_audio, audio_file_path)
An enrollment is how audio samples are associated with a profile (training the service).  For the Identification API a minimum of 30 seconds of recognizable speach is required.  This can be done through multiple enrollments.  This creates a new
enrollment for a profile.

```
Valid Audio Format
-------------------
Container WAV
Encoding  PCM
Rate  16K
Sample Format 16 bit
Channels  Mono
```

```ruby
  profile_id    = "1234567890"
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio   = true # true - set minimum duration to 1 sec (5 sec by default per enrollment)
  identification.create_enrollment(profile_id, short_audio, path_to_audio)
  # returns an operation url that you can use to check the status of the enrollment
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B5"
```

#### delete_profile(profileId)
Delete a particular profile from the service.
```ruby
  profile_id = "1234567890"
  identification.delete_profile(profile_id)
  # => true || false
```

#### get_all_profiles
Returns a list of all the profiles for this account.
```ruby
    identification.get_all_profiles
    # => 
    # [
    #   {
    #     "identificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
    #     "locale" => "en-US",
    #     "enrollmentSpeechTime" => 0.0
    #     "remainingEnrollmentSpeechTime" => 0.0,
    #     "createdDateTime" => "2015-04-23T18:25:43.511Z",
    #     "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
    #     "enrollmentStatus" => "Enrolled" //[Enrolled | Enrolling | Training]
    #   }, ...
    # ]
```

#### get_profile(profileId)
Returns a profile's details
```ruby
  profile_id = "1234567890"
  identification.get_profile(profile_id)
  # =>
  #   {
  #     "identificationProfileId" => "111f427c-3791-468f-b709-fcef7660fff9",
  #     "locale" => "en-US",
  #     "enrollmentSpeechTime" => 0.0,
  #     "remainingEnrollmentSpeechTime" => 0.0,
  #     "createdDateTime" => "2015-04-23T18:25:43.511Z",
  #     "lastActionDateTime" => "2015-04-23T18:25:43.511Z",
  #     "enrollmentStatus" => "Enrolled" //[Enrolled | Enrolling | Training]
  #   }
```

#### reset_all_enrollments_for_profile(profileId)
Resets all the enrollments for a particular profile
```ruby
  profile_id = "1234567890"
  identification.reset_all_enrollments_for_profile(profile_id)
  # => true || false
```

#### identify_speaker(profile_ids, short_audio, audio_file_path)
Identify a speaker by calling this method with an array of `enrolled` profile_ids.
Use ```short_audio``` to wave the required 5-second speech sample.
The audio sample to be analyzed should ideally be 30 seconds, with a maximum of 5 mins.

```
Valid Audio Format
-------------------
Container WAV
Encoding  PCM
Rate  16K
Sample Format 16 bit
Channels  Mono
```

```ruby
  profile_ids   = ["profile_id_1", "profile_id_2", ...]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio   = true
  identification.identify_speaker(profile_ids, short_audio, path_to_audio)
``` 

### Verification API
Verify that a person is who they say they are - this is a text-dependent api.
Prior to being able to verify a speaker, a speaker (profile) must send three audio samples (from an API provided list) with their enrollment.


