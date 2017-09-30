cask 'zulu@9' do
  version '9.0.0.15'
  sha256 '90bc8fc8d76a5e62a02beeb94d933b70c4ecca8397534db09155c752d41ae734'

  # cdn.azul.com was verified as official when first introduced to the cask
  url "https://cdn.azul.com/zulu/bin/zulu#{version}-jdk#{version.major}.#{version.minor}.#{version.patch}-macosx_x64.dmg",
      referer: 'https://zulu.org/download/?platform=MacOS'
  name 'Zulu Java SE 9 Development Kit'
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
