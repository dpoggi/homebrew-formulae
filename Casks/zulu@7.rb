cask 'zulu@7' do
  version '1.7.0_141,7.18.0.3'
  sha256 'f72ecbb7c34a190718eb4d222328dfdf81fbd4fecee847bada28285cf12f58e7'

  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-jdk#{version.minor}.#{version.patch}.#{version.before_comma.sub(/^.*_/, '')}-macosx_x64.dmg",
      referer: 'http://www.azul.com/downloads/zulu/zulu-mac/'
  name 'Azul Zulu Java SE 7 Development Kit'
  homepage 'https://www.azul.com/products/zulu-and-zulu-enterprise/'

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
