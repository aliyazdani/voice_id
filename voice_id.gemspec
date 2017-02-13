Gem::Specification.new do |s|
  s.name        = "voice_id"
  s.version     = "0.1.2"
  s.date        = "2017-02-13"
  s.summary     = "Ruby Wrapper for Microsoft Cognitive Services Speaker Recognition API"
  s.description = "Exposes easy-to-use methods to work with Microsoft's Speach Recognition API and identify people by their voice.  Useful for identifying your users by speech."
  s.authors     = ["Ali Yazdani"]
  s.email       = "aliyazdani82@gmail.com"
  s.files       = Dir["{lib,spec}/**/*", "[A-Z]*"] - ["Gemfile.lock"]
  s.require_path = "lib"
  s.homepage    = "http://rubygems.org/gems/voice_id"
  s.license     = "MIT"

  s.add_runtime_dependency     "http", "~>2.0"
  s.add_development_dependency "rspec", "~> 3.4"
  s.add_development_dependency "mimic", "~> 0.4"
end
