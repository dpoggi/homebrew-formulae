cask 'zulu@11' do
  version '11.39.15,11.0.7'
  sha256 '8322cb6498076f171ab5efa4101fe8207d9aa6517d1d743bbe4d753b67abc8cb'

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
