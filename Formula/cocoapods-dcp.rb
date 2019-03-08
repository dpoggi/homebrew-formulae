class CocoapodsDcp < Formula
  desc "Dependency manager for Cocoa projects, with preinstalled plugins"
  homepage "https://cocoapods.org/"
  url "https://github.com/CocoaPods/CocoaPods/archive/1.5.3.tar.gz"
  sha256 "04593483efe1279c93cfc2bf25866a6e1a3d0c49c0c10602b060611c1e8b5e20"
  revision 4

  devel do
    url "https://github.com/CocoaPods/CocoaPods/archive/1.7.0.beta.1.tar.gz"
    sha256 "d15c177539d92e9dcb96ca94c48c29337e149e010e34a3012e79a310e802fe0e"
  end

  depends_on "ruby" if MacOS.version <= :sierra

  conflicts_with "cocoapods", :because => "both install `pod` and `xcodeproj` binaries"

  def install
    ENV["GEM_HOME"] = libexec

    system "gem", "build", "cocoapods.gemspec"
    system "gem", "install", "cocoapods-#{version}.gem"

    system "gem", "install", "cocoapods-art", "-v", "1.0.2"
    system "gem", "install", "cocoapods-dependencies", "-v", "1.3.0"
    system "gem", "install", "cocoapods-docs", "-v", "0.2.0"
    system "gem", "install", "cocoapods-keys", "-v", "2.1.0"
    system "gem", "install", "cocoapods-packager", "-v", "1.5.0"
    system "gem", "install", "cocoapods-rome", "-v", "1.0.1"

    inreplace libexec/"gems/RubyInline-3.12.4/lib/inline.rb",
              "RUBY_PLATFORM =~ /mingw/",
              "RUBY_PLATFORM =~ /mingw/; cmd = cmd.sub(/^xcrun /, 'xcrun --sdk macosx ') if RUBY_PLATFORM =~ /darwin/"

    bin.install libexec/"bin/pod", libexec/"bin/xcodeproj"

    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"], :INLINEDIR => "#{HOMEBREW_PREFIX}/var/cache")
  end

  test do
    system "#{bin}/pod", "list"
  end
end
