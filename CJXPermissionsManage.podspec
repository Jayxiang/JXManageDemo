Pod::Spec.new do |s|
s.name         = "CJXPermissionsManage"
s.version      = "1.0.0"
s.summary      = "常用权限判断"
s.homepage     = "https://github.com/Jayxiang/JXManageDemo"
s.license      = "MIT"
s.author       = { "jayxiang" => "610469644@qq.com" }
s.platform     = :ios
s.ios.deployment_target = "9.0"
s.source       = { :git => "https://github.com/Jayxiang/JXManageDemo", :tag => "1.0.0" }
s.requires_arc = true
s.source_files = "CJXPermissionsManage/*.{h,m}"
s.frameworks   = "Photos","Contacts","CoreLocation","CoreBluetooth","UserNotifications","EventKit"
end
