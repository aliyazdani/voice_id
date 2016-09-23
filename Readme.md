![](https://img.shields.io/badge/license-MIT-blue.svg)
[![CircleCI](https://circleci.com/gh/aliyazdani/voice_id.svg?style=svg)](https://circleci.com/gh/aliyazdani/voice_id)

# VoiceId
  Wrapper around Microsoft Cognitive Services - Speaker Recognition API

## Installation
  sign up and pick up a new api key (speaker recognition API key) 
  [https://www.microsoft.com/cognitive-services](https://www.microsoft.com/cognitive-services)

  ```
  $ gem install voice_id
  ```

## Examples
  

```ruby
  #create a new profile
  identification = VoiceId::Identification.new("MS_speaker_recognition_api_key")
  profile        = identification.create_profile
  # => { "identificationProfileId" => "49a46324-fc4b-4387-aa06-090cfbf0214f" }

  # create a new enrollment for that profile
  profile_id    = profile["identificationProfileId"]
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio   = true
  operation_url = identification.create_enrollment(profile_id , short_audio, path_to_audio)
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B5"

  # check the status of operation
  operation_id = identification.get_operation_id(operation_url)
  # => "EF217D0C-9085-45D7-AAE0-2B36471B89B5"

  identification.get_operation_status(operation_id)
  # notice below that we only had 13.6 seconds of useable audio so we need to
  # submit more enrollments for this profile until we achieve at min 30 seconds
  # => 
  #   {
  #    "status" => "succeeded", 
  #    "createdDateTime" => "2016-09-23T01:34:44.226642Z",
  #    "lastActionDateTime" => "2016-09-23T01:34:44.4795299Z",
  #    "processingResult" => {
  #      "enrollmentStatus" => "Enrolling", 
  #      "remainingEnrollmentSpeechTime" => 16.4, 
  #      "speechTime" => 13.6, 
  #      "enrollmentSpeechTime"=>13.6
  #    }
  #   }

  # identify a speaker
  profile_ids                  = ["49a46324-fc4b-4387-aa06-090cfbf0214f", "49a36324-fc4b-4387-aa06-091cfbf0216b", ...]
  path_to_test_audio           = '/path/to/some/audio_file.wav'
  short_audio                  = true
  identification_operation_url = identification.identify_speaker(profile_ids, short_audio, path_to_test_audio)
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B6"
  identification_operation_id = identification.get_operation_id(identification_operation_url)
  # => "EF217D0C-9085-45D7-AAE0-2B36471B89B6"
  identification.get_operation_status(identification_operation_id)
  # => 
  # {
  #  "status" => "succeeded", 
  #  "createdDateTime" => "2016-09-23T02:01:54.6498703Z",
  #  "lastActionDateTime" => "2016-09-23T02:01:56.054633Z",
  #  "processingResult" => {
  #    "identifiedProfileId" => "49a46324-fc4b-4387-aa06-090cfbf0214f", 
  #    "confidence"=>"High"
  #   }
  # }
```

## APIs
  Provides methods for two APIs (Identification and Verification)
  All audio samples provided to the API must be the following format:
  ```
  Container WAV
  Encoding  PCM
  Rate  16K
  Sample Format 16 bit
  Channels  Mono
  ```

### Identification API
Identify a person from a list of people - this is a text-independant api.
Prior to being able to identify a speaker, a speaker (profile) must send a minimum
of 30 seconds of recognizable audio.
```ruby
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

```ruby
  profile_id    = "1234567890"
  path_to_audio = '/path/to/some/audio_file.wav'
  short_audio   = true # true - set minimum duration to 1 sec (5 sec by default per enrollment)
  identification.create_enrollment(profile_id, short_audio, path_to_audio)
  # returns an operation url that you can use to check the status of the enrollment
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B5"
```
#### get_operation_id(operation_status_url)
Certain endpoints take time to process to they return a url for you to check on the status of the operation.  To parse out the operation id use this method.  Now you can use #get_operation_status to
check the id.
```ruby
  operation_status_url = identification.create_enrollment(profile_id, short_audio, path_to_audio)
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B5"
  identification_operation_id = identification.get_operation_id(operation_status_url)
  # => "EF217D0C-9085-45D7-AAE0-2B36471B89B6"
```
#### get_operation_status(operation_id)
Check on the status of an operation by passing in the operation id (use #get_operation_id to get the id)
```ruby
  identification.get_operation_status(identification_operation_id)
  # => 
  # {
  #  "status" => "succeeded", 
  #  "createdDateTime" => "2016-09-23T02:01:54.6498703Z",
  #  "lastActionDateTime" => "2016-09-23T02:01:56.054633Z",
  #  "processingResult" => {
  #    "identifiedProfileId" => "49a59333-ur9d-4387-wd06-880cfby0215f", 
  #    "confidence"=>"High"
  #   }
  # }
```

#### delete_profile(profile_id)
Delete a particular profile from the service.
```ruby
  profile_id = "1234567890"
  identification.delete_profile(profile_id)
  # => true
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
  # => true
```

#### identify_speaker(profile_ids, short_audio, audio_file_path)
Identify a speaker by calling this method with an array of `enrolled` profile_ids.
Use ```short_audio``` to wave the required 5-second speech sample.
The audio sample to be analyzed should ideally be 30 seconds, with a maximum of 5 mins.

```ruby
  profile_ids   = ["49a46324-fc4b-4387-aa06-090cfbf0214f", "49a36324-fc4b-4387-aa06-091cfbf0216b", ...]
  path_to_test_audio = '/path/to/some/audio_file.wav'
  short_audio   = true
  identification_operation_url     = identification.identify_speaker(profile_ids, short_audio, path_to_test_audio)
  # => "https://api.projectoxford.ai/spid/v1.0/operations/EF217D0C-9085-45D7-AAE0-2B36471B89B6"
  identification_operation_id = identification.get_operation_id(identification_operation_url)
  # => "EF217D0C-9085-45D7-AAE0-2B36471B89B6"
  identification.get_operation_status(identification_operation_id)
  # => 
  # {
  #  "status" => "succeeded", 
  #  "createdDateTime" => "2016-09-23T02:01:54.6498703Z",
  #  "lastActionDateTime" => "2016-09-23T02:01:56.054633Z",
  #  "processingResult" => {
  #    "identifiedProfileId" => "49a46324-fc4b-4387-aa06-090cfbf0214f", 
  #    "confidence"=>"High"
  #   }
  # }
``` 

### Verification API
Verify that a person is who they say they are - this is a text-dependent api.
Prior to being able to verify a speaker, a speaker (profile) must send three audio samples (from an API provided list) with their enrollment.
```ruby
verification = VoiceId::Verification.new("MS_speaker_recognition_api_key")
```

#### list_all_verification_phrases
Get a list of accepted scripts to use when sending your audio sample.
```ruby
  verification.list_all_verification_phrases
  # =>
  #  [
  #   {"phrase" => "i am going to make him an offer he cannot refuse"}, 
  #   {"phrase" => "houston we have had a problem"}, 
  #   {"phrase" => "my voice is my passport verify me"}, 
  #   {"phrase" => "apple juice tastes funny after toothpaste"}, 
  #   {"phrase" => "you can get in without your password"}, 
  #   {"phrase" => "you can activate security system now"}, 
  #   {"phrase" => "my voice is stronger than passwords"}, 
  #   {"phrase" => "my password is not your business"}, 
  #   {"phrase" => "my name is unknown to you"}, 
  #   {"phrase" => "be yourself everyone else is already taken"}
  #  ]
```

#### create_profile
Same as Identification API

#### create_enrollment(profile_id, audio_file_path)
Requires 3 enrollments.  Pick 3 of the acceptable phrases from `#list_all_verification_phrases` and enroll them.
```ruby
  verification.create_enrollment("49a46324-fc4b-4387-aa06-090cfbf0214f", '/path/to/audio/make_him_an_offer.wav')
  # =>
  #   {
  #     "enrollmentStatus" => "Enrolling",
  #     "enrollmentsCount" => 1,
  #     "remainingEnrollments" => 2,
  #     "phrase" => "i am going to make him an offer he cannot refuse"
  #   }
```

#### delete_profile(profile_id)
Same as Identification API

#### get_all_profiles
Same as Identification API

#### get_profile(profile_id)
Same as Identification API

#### reset_all_enrollments_for_profile(profile_id)
Same as Identification API

#### verify_speaker(profile_id, audio_file_path)
User (profile) would have had to enroll with 3 of the accepted phrases (#list_all_verification_phrases).
Once the phrases have been accepted, a recording of one of the accepted phrases can be checked against an *enrolled* profile.
```ruby
  verification.verify_speaker("86935587-b631-4cc7-a59t-8e580d71522g", "/path/to/audio/offer_converted.wav")
  # =>
  #   {
  #    "result" => "Accept", 
  #    "confidence" => "High", 
  #    "phrase" => "i am going to make him an offer he cannot refuse"
  #   }
```