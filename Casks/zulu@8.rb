cask 'zulu@8' do
  version '1.8.0_202,8.36.0.1'
  sha256 '92b313e3c8da4a5b75288a41ff884374b1de1c596ca1da026c795319637d0071'

  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-ca-jdk#{version.minor}.#{version.patch}.#{version.before_comma.sub(%r{^.*_}, '')}-macosx_x64.dmg",
      referer: 'https://www.azul.com/downloads/zulu/zulu-mac/'
  name 'Azul Zulu OpenJDK 8'
  homepage 'https://www.azul.com/products/zulu-enterprise/'

  conflicts_with cask: 'zulu8'

  pkg "Double-Click to Install Zulu #{version.minor}.pkg"

  postflight do
    system_command '/bin/mv',
                   args: ['-f', '--', "/Library/Java/JavaVirtualMachines/zulu-#{version.minor}.jdk", "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Info.plist"],
                   sudo: true
  end

  uninstall pkgutil: [
                       "com.azulsystems.zulu.#{version.minor}",
                     ],
            delete:  [
                       "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk",
                     ]
end
