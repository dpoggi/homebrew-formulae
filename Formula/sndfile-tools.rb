class SndfileTools < Formula
  desc "Small collection of programs built on libsndfile"
  homepage "http://www.mega-nerd.com/libsndfile/tools/"
  url "http://www.mega-nerd.com/libsndfile/files/sndfile-tools-1.04.tar.bz2"
  sha256 "964a6638ecfafe213c2afc232a463404b2e7330513bd0aec5a385f53e50f6b90"
  license "GPL-2.0-or-later"

  livecheck do
    url :homepage
    regex(/href=.*?sndfile-tools[._-]v?([\d.]+)\.t/i)
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "cairo"
  depends_on "fftw"
  depends_on "libsamplerate"
  depends_on "libsndfile"

  def install
    ENV["SAMPLERATE_CFLAGS"] = "-I#{Formula["libsamplerate"].include}"
    ENV["SAMPLERATE_LIBS"] = "-L#{Formula["libsamplerate"].lib} -lsamplerate"

    system "autoreconf", "-fvi"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"

    (bin/"sndfile-resample").unlink  # Conflicts with libsamplerate
  end

  test do
    mktemp "sndfile" do
      system bin/"sndfile-mix-to-mono", test_fixtures("test.wav").to_s, "./out.wav"
    end
  end
end
