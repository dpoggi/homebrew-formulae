cask 'zulu@11' do
  version '11.37.17,11.0.6'
  sha256 'bcc8ec14b084140941092e16c8d5183964f3c512a354535770897b0cf542730d'

  url "https://cdn.azul.com/zulu/bin/zulu#{version.before_comma}-ca-jdk#{version.after_comma}-macosx_x64.dmg",
      referer: 'https://www.azul.com/downloads/zulu-community/'
  name 'Azul Zulu OpenJDK 11'
  homepage 'https://www.azul.com/products/zulu-community/'

  pkg "Double-Click to Install Zulu #{version.major}.pkg"

  postflight do
    jvm_dir = "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma.sub(%r{_.*$}, '')}.jdk"
    system_command '/bin/mv',
                   args: ['-f', '--', "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk", jvm_dir],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "#{jvm_dir}/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "#{jvm_dir}/Contents/Info.plist"],
                   sudo: true
  end

  uninstall pkgutil: [
                       "com.azulsystems.zulu.#{version.major}",
                     ],
            delete:  [
                       "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma.sub(%r{_.*$}, '')}.jdk",
                     ]
end
