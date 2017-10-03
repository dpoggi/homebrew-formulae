class EmacsDcp < Formula
  desc "GNU Emacs text editor"
  homepage "https://www.gnu.org/software/emacs/"
  url "https://github.com/emacs-mirror/emacs.git", :branch => "emacs-26"
  version "26.0.60"

  option "without-cocoa",
         "Build a non-Cocoa version of Emacs"
  option "without-modules",
         "Build without dynamic modules support"
  option "without-spacemacs-icon",
         "Build without Spacemacs icon by Nasser Alshammari"
  option "with-natural-title-bar",
         "Experimental: use a title bar color inferred from your theme"

  depends_on "autoconf" => :build
  depends_on "dbus"
  depends_on "gnu-sed" => :build
  depends_on "gnutls"
  # Emacs does not support ImageMagick 7:
  # Reported on 2017-03-04: https://debbugs.gnu.org/cgi/bugreport.cgi?bug=25967
  depends_on "imagemagick@6" => :recommended
  depends_on "librsvg" => :recommended
  depends_on "little-cms2"
  depends_on "mailutils" => :optional
  depends_on "pkg-config" => :build
  depends_on "texinfo" => :build

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
      --with-dbus
      --with-gnutls
      --with-lcms2
      --with-xml2
    ]

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

    ENV.prepend_path "PATH", Formula["gnu-sed"].opt_libexec/"gnubin"
    system "./autogen.sh"

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
      args << "--without-x"
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

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>KeepAlive</key>
      <dict>
        <key>Crashed</key>
        <true/>
        <key>SuccessfulExit</key>
        <false/>
      </dict>
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
