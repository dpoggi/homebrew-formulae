cask 'zulu@8' do
  version '1.8.0_152,8.25.0.1'
  sha256 '759ce7f4c13860e90795b96c77f4c0ad5016f7a620a9e6fbde41d639880c7528'

  # cdn.azul.com was verified as official when first introduced to the cask
  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-jdk#{version.minor}.#{version.patch}.#{version.before_comma.sub(%r{^.*_}, '')}-macosx_x64.dmg",
      referer: 'https://zulu.org/download/?platform=MacOS'
  name 'Zulu Java SE 8 Development Kit'
  homepage 'https://zulu.org/'

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
