class Pronterface < Formula
  include Language::Python::Virtualenv

  desc "3D printing host software written in pure Python"
  homepage "https://github.com/kliment/Printrun"
  url "https://github.com/kliment/Printrun/archive/printrun-2.0.0rc7.tar.gz"
  sha256 "28df9e4427ff265dd534414d8ff08029471c58c4a94082d022e3c9336fca527b"
  license "GPL-3.0-only"
  head "https://github.com/kliment/Printrun.git"

  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libffi"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on macos: :mojave
  depends_on "numpy"
  depends_on "openjpeg"
  depends_on "python@3.9"
  depends_on "zlib"

  resource "Pillow" do
    url "https://files.pythonhosted.org/packages/2b/06/93bf1626ef36815010e971a5ce90f49919d84ab5d2fa310329f843a74bc1/Pillow-8.0.1.tar.gz"
    sha256 "11c5c6e9b02c9dac08af04f093eb5a2f84857df70a7d4a6a6ad461aca803fb9e"
  end

  resource "CairoSVG" do
    url "https://github.com/Kozea/CairoSVG/archive/2.5.0.tar.gz"
    sha256 "1560c66c119a1f74348293f484be4aef837b9691502c228e5e0f4824a0b6dfa5"
  end

  resource "PyObjC" do
    url "https://github.com/ronaldoussoren/pyobjc/archive/v6.2.3.tar.gz"
    sha256 "64408e79790e68cdd1c1b385b23b571b5de56fcac2a9160e2972c2f3181289fb"
  end

  resource "wxPython" do
    url "https://files.pythonhosted.org/packages/b0/4d/80d65c37ee60a479d338d27a2895fb15bbba27a3e6bb5b6d72bb28246e99/wxPython-4.1.1.tar.gz"
    sha256 "00e5e3180ac7f2852f342ad341d57c44e7e4326de0b550b9a5c4a8361b6c3528"
  end

  def install
    venv = virtualenv_create(libexec, Formula["python@3.9"].opt_bin/"python3")

    resource("Pillow").stage do
      ENV["FREETYPE_ROOT"] = Formula["freetype"].opt_prefix.to_s
      ENV["JPEG2K_ROOT"] = Formula["openjpeg"].opt_prefix.to_s
      ENV["JPEG_ROOT"] = Formula["jpeg"].opt_prefix.to_s
      ENV["LCMS_ROOT"] = Formula["little-cms2"].opt_prefix.to_s
      ENV["TIFF_ROOT"] = Formula["libtiff"].opt_prefix.to_s
      ENV["ZLIB_ROOT"] = Formula["zlib"].opt_prefix.to_s

      unless MacOS::CLT.installed?
        ENV.append "CFLAGS", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers"
      end

      system libexec/"bin/pip", "install", "-v", "--no-deps", "--no-binary", ":all:",
                                "--ignore-installed", Pathname.pwd,
                                "--global-option=build_ext", "--global-option=--disable-xcb"
    end

    resource("CairoSVG").stage do
      system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:", Pathname.pwd
    end

    resource("PyObjC").stage do
      venv.pip_install(Pathname.pwd / 'pyobjc-core')
      venv.pip_install(Pathname.pwd / 'pyobjc-framework-Cocoa')
    end

    resource("wxPython").stage do
      inreplace "buildtools/build_wxwidgets.py", "#wxpy_configure_opts.append(\"--enable-monolithic\")",
                                                 "wxpy_configure_opts.append(\"--disable-precomp-headers\")"
      inreplace "wscript", "MACOSX_DEPLOYMENT_TARGET = \"10.6\"",
                           "MACOSX_DEPLOYMENT_TARGET = \"#{MacOS.version}\""
      venv.pip_install Pathname.pwd
    end

    system libexec/"bin/pip", "install", "-v", "--no-binary", ":all:", buildpath
    system libexec/"bin/pip", "uninstall", "-y", "Printrun"
    venv.pip_install_and_link buildpath
  end
end
