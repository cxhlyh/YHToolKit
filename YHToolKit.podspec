#
# Be sure to run `pod lib lint YHToolKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YHToolKit'
  s.version          = '0.1.1'
  s.summary          = '一个集合工具包'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    '一个集合工具包，可以只引入自己需要的部分'
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/cxhlyh/YHToolKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cxhlyh' => '意念联系' }
  s.source           = { :git => 'https://github.com/cxhlyh/YHToolKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.subspec 'YHKit' do |kit|#宏定义以及工具库
    kit.source_files = 'YHToolKit/YHKit/**/*'
    #引入网络图片解析库
    kit.dependency 'Kingfisher'
  end
  
  s.subspec 'YHForm' do |form|#表单组件库 基于UITableView
    form.source_files = 'YHToolKit/YHForm/**/*'
    form.resource_bundles = {
       'YHToolKit_YHForm' => ['YHToolKit/YHForm/Resources/*'];
    }
  end

#  s.source_files = 'YHToolKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YHToolKit' => ['YHToolKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
