cask 'zulu@8' do
  version "1.8.0_302,8.56.0.21-ca"
  sha256 "4e667ac2b946d8890a0d9ffe2168e1ad1ccb3f82c3683ccd3f10ce5349c874a7"

  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-jdk#{version.before_comma[2...].sub("_", ".")}-macosx_x64.dmg",
      referer: "https://www.azul.com/downloads/zulu/zulu-mac/"
  name "Azul Zulu OpenJDK 8"
  desc "Java SE 8 development kit from Azul Systems"
  homepage "https://www.azul.com/products/core/"

  conflicts_with cask: ["adoptopenjdk8", "zulu8"]

  pkg "Double-Click to Install Azul Zulu JDK #{version.minor}.pkg"

  postflight do
    system_command "/bin/mv",
                   args: ["-f",
                          "--",
                          "/Library/Java/JavaVirtualMachines/zulu-#{version.minor}.jdk",
                          "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk"],
                   sudo: true
  end

  uninstall pkgutil: "com.azulsystems.zulu.#{version.minor}",
            delete:  "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk"
end
