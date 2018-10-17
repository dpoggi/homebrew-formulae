class CocoapodsDcp < Formula
  desc "Dependency manager for Cocoa projects, with preinstalled plugins"
  homepage "https://cocoapods.org/"
  url "https://github.com/CocoaPods/CocoaPods/archive/1.5.3.tar.gz"
  sha256 "04593483efe1279c93cfc2bf25866a6e1a3d0c49c0c10602b060611c1e8b5e20"
  revision 1

  devel do
    url "https://github.com/CocoaPods/CocoaPods/archive/1.6.0.beta.1.tar.gz"
    sha256 "6c9704f7e4be0903b57039064eebe445016d5acd5060022731d7c90556920195"
  end

  depends_on "ruby" if MacOS.version <= :sierra

  conflicts_with "cocoapods", :because => "both install `pod` binaries"

  def install
    ENV["GEM_HOME"] = libexec

    system "gem", "build", "cocoapods.gemspec"
    system "gem", "install", "cocoapods-#{version}.gem"

    system "gem", "install", "cocoapods-dependencies", "-v", "1.3.0"
    system "gem", "install", "cocoapods-docs", "-v", "0.2.0"
    system "gem", "install", "cocoapods-rome", "-v", "1.0.0"

    bin.install libexec/"bin/pod", libexec/"bin/sandbox-pod", libexec/"bin/xcodeproj"

    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"])
  end

  test do
    system "#{bin}/pod", "list"
  end
end
