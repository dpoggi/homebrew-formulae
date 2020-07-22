class Fawkes < Formula
  include Language::Python::Virtualenv

  desc "A utility to protect user privacy"
  homepage "http://sandlab.cs.uchicago.edu/fawkes/"
  url "https://files.pythonhosted.org/packages/fb/ab/3d037b729c93a6bc75dadbe2baa4385e9537321c959575159b2d919095a3/fawkes-0.0.8.tar.gz"
  sha256 "668d013e93685efaea5e33869d18e14b53df4d22865261e88d8457040ba9371d"
  head "https://github.com/Shawn-Shan/fawkes.git"

  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on :macos => :mojave
  depends_on "openjpeg"
  depends_on "python@3.7"
  depends_on "zlib"

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/3e/02/b09732ca4b14405ff159c470a612979acfc6e8645dc32f83ea0129709f7a/Pillow-7.2.0.tar.gz"
    sha256 "97f9e7953a77d5a70f49b9a48da7776dc51e9b738151b22dacf101641594a626"
  end

  def install
    ENV["FREETYPE_ROOT"] = Formula["freetype"].opt_prefix.to_s
    ENV["JPEG2K_ROOT"] = Formula["openjpeg"].opt_prefix.to_s
    ENV["JPEG_ROOT"] = Formula["jpeg"].opt_prefix.to_s
    ENV["LCMS_ROOT"] = Formula["little-cms2"].opt_prefix.to_s
    ENV["TIFF_ROOT"] = Formula["libtiff"].opt_prefix.to_s
    ENV["ZLIB_ROOT"] = Formula["zlib"].opt_prefix.to_s

    venv = virtualenv_create(libexec, Formula["python@3.7"].opt_bin/"python3")

    resource("Pillow").stage do
      system libexec/"bin/pip", "install", "-v", "--no-deps", "--no-binary", ":all:",
                                "--ignore-installed", Pathname.pwd,
                                "--global-option=build_ext", "--global-option=--disable-xcb"
    end

    system libexec/"bin/pip", "install", "-v", buildpath
    system libexec/"bin/pip", "uninstall", "-y", "fawkes"

    venv.pip_install_and_link buildpath
  end
end
