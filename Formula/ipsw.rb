class Ipsw < Formula
  desc "Research Swiss Army knife for iOS and macOS"
  homepage "https://github.com/blacktop/ipsw"
  url "https://github.com/blacktop/ipsw/releases/download/v3.1.179/ipsw_3.1.179_macOS_#{Hardware::CPU.arch}_extras.tar.gz"
  if Hardware::CPU.intel?
    sha256 "92cea970e6dd5cf867ad1102503aa5a2b635bef646ec8e6653cfce48306721a2"
  else
    sha256 "ac06d9c23c395aee4470cc4e49ead0f4a31386c3bfa6e5123c6871abb2052d21"
  end
  license "MIT"

  depends_on :macos
  depends_on "bat" => :optional
  depends_on "libusb" => :optional
  depends_on "unicorn" => :optional

  def install
    bin.install "ipsw"

    man1.install Dir["manpages/*"]

    bash_completion.install "completions/_bash" => "ipsw"
    fish_completion.install "completions/_fish" => "ipsw.fish"
    zsh_completion.install "completions/_zsh" => "_ipsw"
  end

  test do
    system bin/"ipsw", "--version"
  end
end
