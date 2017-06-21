cask 'zulu9' do
  version '9.0.0,9.0.0.12'
  sha256 '1e8a5ff26a94f768e2f9a6bec83c0185eff3c08c6c3d1fa52262fd89a1b66b97'

  url "https://cdn.azul.com/zulu-pre/bin/zulu#{version.after_comma}-ea-jdk#{version.before_comma}-macosx_x64.dmg",
      referer: 'https://zulu.org/zulu-9-pre-release-downloads/'
  name 'Azul Zulu Java SE 9 Development Kit'
  homepage 'https://zulu.org/zulu-9-pre-release-downloads/'

  pkg "Double-Click to Install Zulu #{version.major}.pkg"

  postflight do
    # TODO: Use after Java 9 goes final
    # system_command '/bin/mv',
    #                args: ['-f', '--', "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk", "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk"],
    #                sudo: true

    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk/Contents/Info.plist"],
                   sudo: true
  end

  uninstall pkgutil: [
                       "com.azulsystems.zulu.#{version.major}",
                     ],
            delete:  [
                       "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk",
                     ].keep_if { |v| !v.nil? }
end
