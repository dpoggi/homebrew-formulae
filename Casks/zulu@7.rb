cask 'zulu@7' do
  version '1.7.0_262,7.38.0.11'
  sha256 '1506d0ab687d6504b1159b048470982376a55a6925214ab26117f21d4fb0e392'

  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-ca-jdk#{version.minor}.#{version.patch.sub(%r{_}, '.')}-macosx_x64.dmg",
      referer: 'https://www.azul.com/downloads/zulu-community/'
  name 'Azul Zulu OpenJDK 7'
  homepage 'https://www.azul.com/products/zulu-community/'

  conflicts_with cask: 'zulu7'

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
