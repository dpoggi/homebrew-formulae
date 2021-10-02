class OpenocdGd < Formula
  desc "On-chip debugging and in-system programming for GigaDevice CPUs"
  homepage "https://openocd.org/"
  url "https://github.com/GigaDevice-Semiconductor/openocd/archive/refs/tags/v0.10.0-15.tar.gz"
  sha256 "fae049fbe2c6bce072d2fdedd2175bf10277e7ec58ff8b237ecd61c190f5881b"
  license "GPL-2.0-or-later"

  head do
    url "https://github.com/GigaDevice-Semiconductor/openocd.git", branch: "xpack"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "texinfo" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "hidapi"
  depends_on "libftdi"
  depends_on "libusb"
  depends_on "libusb-compat"

  conflicts_with "open-ocd", because: "both install `openocd` binaries"

  def install
    ENV["CCACHE"] = "none"

    system "./bootstrap"
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking", "--enable-branding"
    system "make"
    system "make", "install"
  end

  test do
    assert_match(/^Open On-Chip Debugger 0\.1\d/, shell_output("#{bin}/openocd --version 2>&1"))
  end
end
