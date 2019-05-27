
  Pod::Spec.new do |s|
    s.name = 'CapacitorBackgroundFetch'
    s.version = '0.4.2'
    s.summary = 'Utilizing the iOS background fetch mechanism to fetch new data while the app is in background'
    s.license = 'MIT'
    s.homepage = 'https://github.com/kaunstdadenga/capacitor-background-fetch.git'
    s.author = 'kaunstdadenga'
    s.source = { :git => 'https://github.com/kaunstdadenga/capacitor-background-fetch.git', :tag => s.version.to_s }
    s.source_files = 'ios/BackgroundFetch/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end