cask 'zulu@8' do
  version '1.8.0_222,8.40.0.25'
  sha256 'f01dc7b8856866eddb43a2078daab68a8f3ba357aab23395e942efd7b55025fc'

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
