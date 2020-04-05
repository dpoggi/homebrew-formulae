class CocoapodsDcp < Formula
  desc "Dependency manager for Cocoa projects, with preinstalled plugins"
  homepage "https://cocoapods.org/"
  url "https://github.com/CocoaPods/CocoaPods/archive/1.9.1.tar.gz"
  sha256 "c5ce17f20f93cba55bde13e9e6e87b1f49b312ab27db4f259226d2c019953bcf"

  depends_on "ruby" if MacOS.version <= :sierra

  conflicts_with "cocoapods", :because => "both install `pod` binaries"

  def install
    ENV["GEM_HOME"] = libexec
    ENV["SDKROOT"] = ENV["HOMEBREW_SDKROOT"] = MacOS.sdk_path

    system "gem", "build", "cocoapods.gemspec"
    system "gem", "install", "cocoapods-#{version}.gem"

    system "gem", "install", "ruby-graphviz", "-v", "1.2.4" if MacOS.version < :catalina

    system "gem", "install", "cocoapods-art", "-v", "1.0.4"
    system "gem", "install", "cocoapods-dependencies", "-v", "1.3.0"
    system "gem", "install", "cocoapods-docs", "-v", "0.2.0"
    system "gem", "install", "cocoapods-keys", "-v", "2.1.0"
    system "gem", "install", "cocoapods-rome", "-v", "1.0.1"

    inreplace libexec/"gems/RubyInline-3.12.5/lib/inline.rb",
              "if recompile then",
              "if recompile then\n          RbConfig::CONFIG['srcdir'] = RbConfig::CONFIG['includedir']"

    bin.install libexec/"bin/pod"

    bin.env_script_all_files libexec/"bin",
                             :GEM_HOME  => ENV["GEM_HOME"],
                             :INLINEDIR => "#{HOMEBREW_PREFIX}/var/cache",
                             :SDKROOT   => ENV["SDKROOT"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pod --version 2>/dev/null")
  end
end
