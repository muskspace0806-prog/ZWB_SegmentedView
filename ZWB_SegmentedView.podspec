Pod::Spec.new do |s|
  s.name         = "ZWB_SegmentedView"
  s.version      = "1.0.0"
  s.summary      = "A maintained JXSegmentedView fork with ZWB custom menu helpers."
  s.homepage     = "https://github.com/muskspace0806-prog/ZWB_SegmentedView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "hule" => "hule" }
  s.platform     = :ios, "9.0"
  s.swift_version = "5.0"
  s.source       = { :git => "https://github.com/muskspace0806-prog/ZWB_SegmentedView.git", :tag => s.version.to_s }
  s.framework    = "UIKit"
  s.source_files = "Sources", "Sources/**/*.{swift}"
  s.resource_bundles = { "ZWB_SegmentedView" => ["Sources/PrivacyInfo.xcprivacy"] }
  s.requires_arc = true
end

