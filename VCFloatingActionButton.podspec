Pod::Spec.new do |s|

  s.name         = "VCFloatingActionButton"
  s.version      = "1.0"
  s.summary      = "VCFloatingActionButton like Inbox floating button"

  s.homepage     = "https://github.com/nartex/VCFloatingActionButton"
  s.screenshots  = ""

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = "gizmoboy7"
  s.social_media_url   = ""

  s.platform     = :ios
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/nartex/VCFloatingActionButton.git", :tag => s.version.to_s }

  s.source_files  = "VCFloatingActionButton", "VCFloatingActionButton/floatingButtonTrial/VCFloatingActionButton/*.{h,m,xib}"

  s.requires_arc = true
  
end
