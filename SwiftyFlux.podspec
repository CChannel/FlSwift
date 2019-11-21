Pod::Spec.new do |s|
  s.name         = "Swifty-Flux"
  s.version      = "0.0.1"
  s.summary      = "Flux for Swift"
  s.homepage     = "https://github.com/CChannel/Swifty-Flux"
  s.license      = "MIT"
  s.source       = { :git => "https://github.com/CChannel/Swifty-Flux.git", :tag => "#{s.version}" }
  s.source_files = "SwiftyFlux/*.swift"
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.swift_version = "5.0"
end
