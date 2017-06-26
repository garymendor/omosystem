Gem::Specification.new do |s|
  s.name        = 'OmoSystem'
  s.version     = '0.0.1'
  s.date        = '2017-06-23'
  s.summary     = "OmoSystem"
  s.description = "A system for simulating bodily functions and the consequences thereof."
  s.authors     = ["garador"]
  s.email       = 'gary.mendor@gmail.com'
  s.files       = [
    "lib/OmoSystem.rb",
    "lib/OmoSystem_Integration.rb",
    "lib/VXA_DefaultScripts.rb",
    "test/OmoSystemModule.rb"
  ]
  s.homepage    =
    'https://www.omorashi.org/profile/26131-garador/'
  s.license       = 'MIT'

  s.add_runtime_dependency 'rpg-maker-rgss3', '~> 1.02.0'
end