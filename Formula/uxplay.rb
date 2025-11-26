class Uxplay < Formula
  desc "AirPlay Unix mirroring server"
  homepage "https://github.com/FDH2/UxPlay"
  url "https://github.com/FDH2/UxPlay/archive/refs/tags/v1.72.2.tar.gz"
  sha256 "9d144c5439f1736c98227c64020f3b07294cd17e5f27a205d1d4a4e950c322c0"
  license "GPL-3.0-only"
  head "https://github.com/FDH2/UxPlay.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "gstreamer"
  depends_on "libplist"
  depends_on "openssl@3"

  def install
    args = %W[
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  service do
    run [opt_bin/"uxplay"]
    run_at_load true
    keep_alive crashed: true, successful_exit: false
    log_path var/"log/uxplay.log"
    error_log_path var/"log/uxplay.log"
  end

  test do
    assert_match "UxPlay version #{version.major_minor}", shell_output("#{bin}/uxplay -v")
  end
end
