Pod::Spec.new do |s|
s.name         = 'mxhDemo'
s.version      = '1.2'
s.summary      = 'scrollerview滑动'
s.homepage     = 'https://github.com/maoxiaohong/mxhDemo'
s.license      = 'MIT'
s.authors      = {'maoxiaohong' => '825823903@qq.com'}
s.platform     = :ios, '6.0'
s.source       = {:git => 'https://github.com/maoxiaohong/mxhDemo.git', :tag => s.version}
s.source_files = 'mxhDemo/*'
s.requires_arc = true
end

