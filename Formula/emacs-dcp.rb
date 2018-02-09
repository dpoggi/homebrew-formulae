class EmacsDcp < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://alpha.gnu.org/gnu/emacs/pretest/emacs-26.0.91.tar.xz"
  sha256 "31f6bb353e13d337e10160f778608e342becd213fbb21c9f08085abe318381a0"

  head do
    url "https://gitub.com/emacs-mirror/emacs.git", :branch => "emacs-26"

    depends_on "autoconf" => :build
    depends_on "gnu-sed" => :build
    depends_on "texinfo" => :build
  end

  option "without-cocoa",
         "Build a non-Cocoa version of Emacs"
  option "without-modules",
         "Build without dynamic modules support"
  option "without-spacemacs-icon",
         "Build without Spacemacs icon by Nasser Alshammari"

  depends_on "dbus"
  depends_on "gnutls"
  # Emacs does not support ImageMagick 7:
  # Reported on 2017-03-04: https://debbugs.gnu.org/cgi/bugreport.cgi?bug=25967
  depends_on "imagemagick@6"
  depends_on "librsvg"
  depends_on "little-cms2"
  depends_on "mailutils" => :optional
  depends_on "pkg-config" => :build

  conflicts_with "emacs", :because => "they install conflicting executables"

  patch do
    url "https://gist.githubusercontent.com/aatxe/260261daf70865fbf1749095de9172c5/raw/214b50c62450be1cbee9f11cecba846dd66c7d06/patch-multicolor-font.diff"
    sha256 "5af2587e986db70999d1a791fca58df027ccbabd75f45e4a2af1602c75511a8c"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp
      --infodir=#{info}/emacs
      --prefix=#{prefix}
      --without-x
      --with-dbus
      --with-gnutls
      --with-imagemagick
      --with-lcms2
      --with-rsvg
      --with-xml2
    ]

    args << "--with-modules" if build.with? "modules"
    args << "--without-pop" if build.with? "mailutils"

    if build.head?
      ENV.prepend_path "PATH", Formula["gnu-sed"].opt_libexec/"gnubin"
      system "./autogen.sh"
    end

    if build.with? "cocoa"
      args << "--with-ns" << "--disable-ns-self-contained"
    else
      args << "--without-ns"
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    if build.with? "cocoa"
      # icons
      if build.with? "spacemacs-icon"
        icon_file = "nextstep/Emacs.app/Contents/Resources/Emacs.icns"
        spacemacs_icons = "https://github.com/nashamri/spacemacs-logo/blob/master/spacemacs.icns?raw=true"
        rm icon_file
        curl "-fsSL", spacemacs_icons, "-o", icon_file
      end

      prefix.install "nextstep/Emacs.app"

      # Replace the symlink with one that avoids starting Cocoa.
      (bin/"emacs").unlink # Kill the existing symlink
      (bin/"emacs").write <<~EOS
        #!/bin/sh
        exec "#{prefix}/Emacs.app/Contents/MacOS/Emacs" "$@"
      EOS
    end

    # Follow MacPorts and don't install ctags from Emacs. This allows Vim
    # and Emacs and ctags to play together without violence.
    (bin/"ctags").unlink
    (man1/"ctags.1.gz").unlink
  end

  plist_options :manual => "emacs"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/emacs</string>
        <string>--fg-daemon</string>
      </array>
    </dict>
    </plist>
  EOS
  end

  test do
    assert_equal "4", shell_output("#{bin}/emacs --batch --eval=\"(print (+ 2 2))\"").strip
  end
end
