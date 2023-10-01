# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GitHubSearch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GitHubSearch

	pod 'SwiftLint'
	pod 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord'

  target 'GitHubSearchTests' do
    inherit! :search_paths
	pod 'Nimble'
  end

  target 'Network' do
    inherit! :search_paths
    # Pods for testing
	pod 'Alamofire'
	pod 'AlamofireNetworkActivityIndicator'

  end

end
