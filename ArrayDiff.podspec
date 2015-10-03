
Pod::Spec.new do |s|
  s.name        = "ArrayDiff"
  s.version     = "1.0.4"
  s.summary     = "ArrayDiff quickly computes the difference between two arrays, works great with UITableView/UICollectionView"
  s.homepage    = "https://github.com/Adlai-Holler/ArrayDiff"
  s.license     = { :type => "MIT" }
  s.authors     = { "Adlai-Holler" => "adlai@icloud.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.source   = { :git => "https://github.com/Adlai-Holler/ArrayDiff.git", :tag => "v1.0.4" }
  s.source_files = "ArrayDiff/*.swift"
end
