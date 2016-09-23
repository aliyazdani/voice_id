require_relative '../voice_id'

i = VoiceId::Identification.new("cf0f820a992f4b0fa4ec9c1c48b37151")
# i = VoiceId::Identification.new("123")
profile = i.create_profile
p profile
# p i.delete_profile("5285a51a-8933-49c9-b605-4533b9de5d5d")
# p i.get_all_profiles
# p i.get_profile("e8cb628f-ad6f-4620-9211-249346befb00")
# p i.reset_all_enrollments_for_profile("e8cb628f-ad6f-4620-9211-249346befb0")
# enroll = i.create_enrollment("c80a3c4d-c850-41d7-a698-1343c8619809", true, "/Users/aliyazdani/Downloads/offer_converted.wav")
# p enroll
# p i.get_operation_status("c1b33aa8-73e4-4df2-b07f-c649686f79a4")
# op = i.identify_speaker(["c80a3c4d-c850-41d7-a698-1343c8619809"], true, "/Users/aliyazdani/Downloads/unhappy_converted.wav")
# p op