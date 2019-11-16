class CocoapodsDcp < Formula
  desc "Dependency manager for Cocoa projects, with preinstalled plugins"
  homepage "https://cocoapods.org/"
  url "https://github.com/CocoaPods/CocoaPods/archive/1.8.4.tar.gz"
  sha256 "7afe0a8f0d1a83d23a3a04c195229c9bec37d114e6b81b41458e65e33138f8c6"

  depends_on "ruby" if MacOS.version <= :sierra

  conflicts_with "cocoapods", :because => "both install `pod` and `xcodeproj` binaries"

  def install
    ENV["GEM_HOME"] = libexec

    system "gem", "build", "cocoapods.gemspec"
    system "gem", "install", "cocoapods-#{version}.gem"

    system "gem", "install", "cocoapods-art", "-v", "1.0.4"
    system "gem", "install", "cocoapods-dependencies", "-v", "1.3.0"
    system "gem", "install", "cocoapods-docs", "-v", "0.2.0"
    system "gem", "install", "cocoapods-keys", "-v", "2.1.0"
    system "gem", "install", "cocoapods-rome", "-v", "1.0.1"

    inreplace libexec/"gems/RubyInline-3.12.5/lib/inline.rb",
              "if recompile then",
              "if recompile then\n          RbConfig::CONFIG['srcdir'] = RbConfig::CONFIG['includedir']"
    inreplace libexec/"gems/RubyInline-3.12.5/lib/inline.rb",
              "RUBY_PLATFORM =~ /mingw/",
              "RUBY_PLATFORM =~ /mingw/\n          cmd = cmd.sub(/^xcrun /, 'xcrun --sdk macosx ') if RUBY_PLATFORM =~ /darwin/"

    bin.install libexec/"bin/pod", libexec/"bin/xcodeproj"

    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"], :INLINEDIR => "#{HOMEBREW_PREFIX}/var/cache")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pod --version 2>/dev/null")
  end
end
