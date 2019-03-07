class CocoapodsDcp < Formula
  desc "Dependency manager for Cocoa projects, with preinstalled plugins"
  homepage "https://cocoapods.org/"
  url "https://github.com/CocoaPods/CocoaPods/archive/1.6.1.tar.gz"
  sha256 "482fbb5c89d1c7c4456f9c1aba3b6ee41cfe74f8ea389a4d3a0b0415d30cda40"

  devel do
    url "https://github.com/CocoaPods/CocoaPods/archive/1.7.0.beta.1.tar.gz"
    sha256 "d15c177539d92e9dcb96ca94c48c29337e149e010e34a3012e79a310e802fe0e"
  end

  depends_on "ruby" if MacOS.version <= :sierra

  conflicts_with "cocoapods", :because => "both install `pod` binaries"

  def install
    ENV["GEM_HOME"] = libexec

    system "gem", "build", "--norc", "cocoapods.gemspec"
    system "gem", "install", "--norc", "cocoapods-#{version}.gem"

    system "gem", "install", "--norc", "cocoapods-art", "--version", "1.0.2"
    system "gem", "install", "--norc", "cocoapods-dependencies", "--version", "1.3.0"
    system "gem", "install", "--norc", "cocoapods-docs", "--version", "0.2.0"
    system "gem", "install", "--norc", "cocoapods-keys", "--version", "2.1.0"
    system "gem", "install", "--norc", "cocoapods-packager", "--version", "1.5.0"
    system "gem", "install", "--norc", "cocoapods-rome", "--version", "1.0.1"

    bin.install libexec/"bin/pod", libexec/"bin/xcodeproj"

    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"])
  end

  test do
    system "#{bin}/pod", "list"
  end
end
