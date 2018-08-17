cask 'zulu@10' do
  version '10.3+5,10.0.2'
  sha256 'dfc5a9cae3fbfb45d565bcd067829b7273704c976ff00a63794c9f9742fe4f76'

  # cdn.azul.com was verified as official when first introduced to the cask
  url "https://cdn.azul.com/zulu/bin/zulu#{version.before_comma}-jdk#{version.after_comma}-macosx_x64.dmg",
      referer: 'https://zulu.org/download/?platform=MacOS'
  name 'Zulu Java SE 10 Development Kit'
  homepage 'https://zulu.org/'

  pkg "Double-Click to Install Zulu #{version.major}.pkg"

  postflight do
    system_command '/bin/mv',
                   args: ['-f', '--', "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk", "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk/Contents/Info.plist"],
                   sudo: true
  end

  uninstall pkgutil: [
                       "com.azulsystems.zulu.#{version.major}",
                     ],
            delete:  [
                       "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk",
                     ]
end
