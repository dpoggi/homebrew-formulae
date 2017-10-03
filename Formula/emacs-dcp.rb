class EmacsDcp < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://ftp.gnu.org/gnu/emacs/emacs-25.3.tar.xz"
  mirror "https://ftpmirror.gnu.org/emacs/emacs-25.3.tar.xz"
  sha256 "253ac5e7075e594549b83fd9ec116a9dc37294d415e2f21f8ee109829307c00b"

  head do
    url "https://github.com/emacs-mirror/emacs.git", :branch => "emacs-26"

    depends_on "autoconf" => :build
    depends_on "gnu-sed" => :build
    depends_on "little-cms2"
    depends_on "texinfo" => :build
  end

  option "without-cocoa",
         "Build a non-Cocoa version of Emacs"
  option "without-modules",
         "Build without dynamic modules support"
  option "without-spacemacs-icon",
         "Build without Spacemacs icon by Nasser Alshammari"
  option "with-x11",
         "Experimental: build with x11 support"
  option "with-natural-title-bar",
         "Experimental: use a title bar colour inferred by your theme"

  deprecated_option "cocoa" => "with-cocoa"
  deprecated_option "with-d-bus" => "with-dbus"

  depends_on "pkg-config" => :build
  depends_on :x11 => :optional
  depends_on "dbus" => :optional
  depends_on "gnutls"
  depends_on "librsvg" => :recommended
  # Emacs does not support ImageMagick 7:
  # Reported on 2017-03-04: https://debbugs.gnu.org/cgi/bugreport.cgi?bug=25967
  depends_on "imagemagick@6" => :recommended
  depends_on "mailutils" => :optional

  if build.with? "x11"
    depends_on "freetype" => :recommended
    depends_on "fontconfig" => :recommended
  end

  conflicts_with "emacs", :because => "they install conflicting executables"

  if build.with? "natural-title-bar"
    patch do
      url "https://gist.githubusercontent.com/jwintz/853f0075cf46770f5ab4f1dbf380ab11/raw/bc30bd2e9a7bf6873f3a3e301d0085bcbefb99b0/emacs_dark_title_bar.patch"
      sha256 "742f7275f3ada695e32735fa02edf91a2ae7b1fa87b7e5f5c6478dd591efa162"
    end
  end

  patch do
    url "https://gist.githubusercontent.com/dpoggi/6613cbb080694024cdeff00261efab44/raw/a38b9f098c0f685b3072d6b9e19a17646537bb0a/multicolor-fonts.patch"
    sha256 "cd4cfc7880f66ca47c53d2b65a433a998a6f0cd82211ee7caac322c5c6366c53"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp
      --infodir=#{info}/emacs
      --prefix=#{prefix}
      --with-gnutls
      --with-xml2
    ]

    if build.with? "dbus"
      args << "--with-dbus"
    else
      args << "--without-dbus"
    end

    # Note that if ./configure is passed --with-imagemagick but can't find the
    # library it does not fail but imagemagick support will not be available.
    # See: https://debbugs.gnu.org/cgi/bugreport.cgi?bug=24455
    if build.with? "imagemagick@6"
      args << "--with-imagemagick"
    else
      args << "--without-imagemagick"
    end

    args << "--with-modules" if build.with? "modules"
    args << "--with-rsvg" if build.with? "librsvg"
    args << "--without-pop" if build.with? "mailutils"

    if build.head?
      args << "--with-lcms2"

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
        curl "-L", spacemacs_icons, "-o", icon_file
      end

      prefix.install "nextstep/Emacs.app"

      # Replace the symlink with one that avoids starting Cocoa.
      (bin/"emacs").unlink # Kill the existing symlink
      (bin/"emacs").write <<-EOS.undent
        #!/bin/bash
        exec #{prefix}/Emacs.app/Contents/MacOS/Emacs "$@"
      EOS
    else
      if build.with? "x11"
        # These libs are not specified in xft's .pc. See:
        # https://trac.macports.org/browser/trunk/dports/editors/emacs/Portfile#L74
        # https://github.com/Homebrew/homebrew/issues/8156
        ENV.append "LDFLAGS", "-lfreetype -lfontconfig"
        args << "--with-x"
        args << "--with-gif=no" << "--with-tiff=no" << "--with-jpeg=no"
      else
        args << "--without-x"
      end
      args << "--without-ns"

      system "./configure", *args
      system "make"
      system "make", "install"
    end

    # Follow MacPorts and don't install ctags from Emacs. This allows Vim
    # and Emacs and ctags to play together without violence.
    (bin/"ctags").unlink
    (man1/"ctags.1.gz").unlink
  end

  plist_options :manual => "emacs"

  def plist
    if build.head?
      disposition = <<-EOS.undent
        <key>KeepAlive</key>
        <dict>
          <key>Crashed</key>
          <true/>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
      EOS
    else
      disposition = <<-EOS.undent
        <key>LaunchOnlyOnce</key>
        <true/>
      EOS
    end

    <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
    #{disposition}
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/emacs</string>
        <string>#{build.head? ? "--fg-daemon" : "--daemon"}</string>
      </array>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_equal "4", shell_output("#{bin}/emacs --batch --eval=\"(print (+ 2 2))\"").strip
  end
end
