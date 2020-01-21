cask 'zulu@7' do
  version '1.7.0_252,7.36.0.5'
  sha256 '7991a2c6beeb08bdfe4943d0f667f837f329e116753d4497b820b9f3f97f7d4c'

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
