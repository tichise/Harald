Pod::Spec.new do |s|
  s.name = 'Harald'
  s.version = '1.0.3'
  s.license = 'MIT'
  s.summary = 'Harald is a BLE library.'
  s.homepage = 'https://github.com/tichise/Harald'
  s.social_media_url = 'http://twitter.com/tichise'
  s.author = "Takuya Ichise"
  s.source = { :git => 'https://github.com/tichise/Harald.git', :tag => s.version }

  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/*.swift'
  s.requires_arc = true

  s.resource_bundles = {
  }
end
