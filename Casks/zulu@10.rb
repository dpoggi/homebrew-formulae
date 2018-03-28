cask 'zulu@10' do
  version '10.1+11'
  sha256 '8888d8260cab86cba06c633d39a03b78982caff3d067c6e5bce7d28e03209b05'

  # cdn.azul.com was verified as official when first introduced to the cask
  url "https://cdn.azul.com/zulu/bin/zulu#{version}-jdk#{version.major}-macosx_x64.dmg",
      referer: 'https://zulu.org/download/?platform=MacOS'
  name 'Zulu Java SE 10 Development Kit'
  homepage 'https://zulu.org/'

  pkg "Double-Click to Install Zulu #{version.major}.pkg"

  postflight do
    system_command '/bin/mv',
                   args: ['-f', '--', "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk", "/Library/Java/JavaVirtualMachines/zulu-#{version}.jdk"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "/Library/Java/JavaVirtualMachines/zulu-#{version}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/zulu-#{version}.jdk/Contents/Info.plist"],
                   sudo: true
  end

  uninstall pkgutil: [
                       "com.azulsystems.zulu.#{version.major}",
                     ],
            delete:  [
                       "/Library/Java/JavaVirtualMachines/zulu-#{version}.jdk",
                     ]
end
