cask 'zulu-9' do
  version '9.0.0,9.0.0.10'
  sha256 '3b349acaaba370724f03b382cfe0672c260c71da7ad54f7490a1967e3c07a516'

  url "https://cdn.azul.com/zulu-pre/bin/zulu#{version.after_comma}-ea-jdk#{version.before_comma}-macosx_x64.dmg",
      referer: 'https://zulu.org/zulu-9-pre-release-downloads/'
  name 'Azul Zulu Java SE 8 Development Kit'
  homepage 'https://zulu.org/zulu-9-pre-release-downloads/'

  pkg "Double-Click to Install Zulu #{version.major}.pkg"

  postflight do
    system_command '/bin/mv',
                   args: ['-f', '--', "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk", "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk"],
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
                     ].keep_if { |v| !v.nil? }
end
