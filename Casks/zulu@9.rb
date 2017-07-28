cask 'zulu@9' do
  version '9.0.0,9.0.0.13'
  sha256 'edfe190664bf8e588cf92925f612ef78d9915e5470c824c1296acb5a72f7654b'

  url "https://cdn.azul.com/zulu-pre/bin/zulu#{version.after_comma}-ea-jdk#{version.before_comma}-macosx_x64.dmg",
      referer: 'https://zulu.org/zulu-9-pre-release-downloads/'
  name 'Azul Zulu Java SE 9 Development Kit'
  homepage 'https://zulu.org/zulu-9-pre-release-downloads/'

  pkg "Double-Click to Install Zulu #{version.major}.pkg"

  postflight do
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk/Contents/Info.plist"],
                   sudo: true
  end

  uninstall pkgutil: [
                       "com.azulsystems.zulu.#{version.major}",
                     ],
            delete:  [
                       "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk",
                     ]
end
