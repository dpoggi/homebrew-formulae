class CocoapodsDcp < Formula
  desc "Dependency manager for Cocoa projects, with preinstalled plugins"
  homepage "https://cocoapods.org/"
  url "https://github.com/CocoaPods/CocoaPods/archive/1.7.5.tar.gz"
  sha256 "508e5f7a7566b3d05ec4e27417dc0a60bedc8e72618b31cb56713034e71337b9"

  depends_on "ruby" if MacOS.version <= :sierra

  conflicts_with "cocoapods", :because => "both install `pod` and `xcodeproj` binaries"

  def install
    ENV["GEM_HOME"] = libexec

    system "gem", "build", "cocoapods.gemspec"
    system "gem", "install", "cocoapods-#{version}.gem"

    system "gem", "install", "cocoapods-art", "-v", "1.0.3"
    system "gem", "install", "cocoapods-dependencies", "-v", "1.3.0"
    system "gem", "install", "cocoapods-docs", "-v", "0.2.0"
    system "gem", "install", "cocoapods-keys", "-v", "2.1.0"
    system "gem", "install", "cocoapods-packager", "-v", "1.5.0"
    system "gem", "install", "cocoapods-rome", "-v", "1.0.1"

    inreplace libexec/"gems/RubyInline-3.12.4/lib/inline.rb",
              "if recompile then",
              "if recompile then\n          RbConfig::CONFIG['srcdir'] = RbConfig::CONFIG['includedir']"
    inreplace libexec/"gems/RubyInline-3.12.4/lib/inline.rb",
              "RUBY_PLATFORM =~ /mingw/",
              "RUBY_PLATFORM =~ /mingw/\n          cmd = cmd.sub(/^xcrun /, 'xcrun --sdk macosx ') if RUBY_PLATFORM =~ /darwin/"

    bin.install libexec/"bin/pod", libexec/"bin/xcodeproj"

    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"], :INLINEDIR => "#{HOMEBREW_PREFIX}/var/cache")
  end

  test do
    system "#{bin}/pod", "list"
  end
end
