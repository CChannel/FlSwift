Pod::Spec.new do |s|
  s.name         = "Swifty_Flux"
  s.version      = "0.0.1"
  s.summary      = "Flux for Swift"
  s.homepage     = "https://github.com/CChannel/Swifty_Flux"
  s.license      = "MIT"
  s.source       = { :git => "https://github.com/CChannel/Swifty_Flux.git", :tag => "#{s.version}" }
  s.author       = { "t-osawa-009" => "da87435@gmail.com" }
  s.source_files = "Source/*.swift"
  s.ios.deployment_target = "10.0"
  s.tvos.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "3.0"
  s.requires_arc = true
  s.swift_version = "5.0"
end
