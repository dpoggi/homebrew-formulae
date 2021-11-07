cask "zulu@11" do
  version "11.0.13,11.52.13-ca"
  sha256 "b780c7934ee5e67b82cd0362dd0295895d53976498b3dccfe18747d98ea27bda"

  url "https://cdn.azul.com/zulu/bin/zulu#{version.after_comma}-jdk#{version.before_comma}-macosx_x64.dmg",
      referer: "https://www.azul.com/downloads/zulu/zulu-mac/"
  name "Azul Zulu OpenJDK 11"
  desc "Java SE 11 development kit from Azul Systems"
  homepage "https://www.azul.com/products/core/"

  conflicts_with cask: "zulu11"

  pkg "Double-Click to Install Azul Zulu JDK #{version.major}.pkg"

  postflight do
    system_command "/bin/mv",
                   args: ["-f",
                          "--",
                          "/Library/Java/JavaVirtualMachines/zulu-#{version.major}.jdk",
                          "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk"],
                   sudo: true
  end

  uninstall pkgutil: "com.azulsystems.zulu.#{version.major}",
            delete:  "/Library/Java/JavaVirtualMachines/zulu-#{version.before_comma}.jdk"
end
