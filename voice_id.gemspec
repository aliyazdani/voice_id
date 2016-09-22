Gem::Specification.new do |s|
  s.name        = "voice_id"
  s.version     = "0.1.0"
  s.date        = "2016-09-16"
  s.summary     = "Ruby Wrapper for Microsoft Cognitive Services Speaker Recognition API"
  s.description = "Exposes easy-to-use methods to work with Microsoft's Speach Recognition API and identify people by their voice.  Useful for identifying your users by speech."
  s.authors     = ["Ali Yazdani"]
  s.email       = "aliyazdani82@gmail.com"
  s.files       = ["lib/voice_id/voice_id.rb"]
  s.homepage    = "http://rubygems.org/gems/voice_id"
  s.license     = "MIT"

  s.add_runtime_dependency     "http", "~>2.0.3"
  s.add_development_dependency "rspec", "~> 3.4.0"
  s.add_development_dependency "mimic", "~> 0.4.4"
end