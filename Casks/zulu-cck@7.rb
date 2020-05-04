cask 'zulu-cck@7' do
  version '1.7.0_262,7.0.0.10'
  sha256 '0c206ae6ba1450bf5e7f6bb07a7dfb30497b49d62694eb9232dab5957918cbd0'

  url "https://cdn.azul.com/zcck/bin/zcck#{version.after_comma}-macosx_x64.sh",
      referer: 'https://www.azul.com/products/zulu-and-zulu-enterprise/cck-downloads/mac-os-x/'
  name 'Commercial Compatibility Kit for Zulu OpenJDK 7'
  homepage 'https://www.azul.com/products/zulu-and-zulu-enterprise/cck-downloads/'

  depends_on cask: 'zulu@7'
  container type: :naked

  postflight do
    installer_path = staged_path.join("zcck#{version.after_comma}-macosx_x64.sh")

    system_command '/bin/sh',
                   args: ['-c', "tail -n \"+$(awk '/^__ARCHIVE_START__/ { print NR + 1; exit 0; }' \"#{installer_path}\")\" \"#{installer_path}\" | tar xf - -C \"#{staged_path}\""]

    java_home = Pathname.new("/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home")

    system_command '/bin/mkdir',
                   args: ['-p', java_home.join('etc')],
                   sudo: true

    Dir.glob(staged_path.join('license', '*')) do |license|
      system_command '/bin/ln',
                     args: ['-nsf', license, java_home.join('etc', File.basename(license))],
                     sudo: true
    end

    system_command '/bin/mkdir',
                   args: ['-p', java_home.join('jre', 'lib', 'fonts')],
                   sudo: true

    Dir.glob(staged_path.join('fonts', '*')) do |font|
      system_command '/bin/ln',
                     args: ['-nsf', font, java_home.join('jre', 'lib', 'fonts', File.basename(font))],
                     sudo: true
    end
  end

  uninstall_postflight do
    java_home = Pathname.new("/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home")

    Dir.glob(staged_path.join('license', '*')) do |license|
      system_command '/bin/rm',
                     args: ['-f', java_home.join('etc', File.basename(license))],
                     sudo: true
    end

    system_command '/bin/sh',
                   args: ['-c', "rmdir #{java_home.join('etc')} 2>/dev/null || true"],
                   sudo: true

    Dir.glob(staged_path.join('fonts', '*')) do |font|
      system_command '/bin/rm',
                     args: ['-f', java_home.join('jre', 'lib', 'fonts', File.basename(font))],
                     sudo: true
    end

    system_command '/bin/sh',
                   args: ['-c', "rmdir #{java_home.join('jre', 'lib', 'fonts')} 2>/dev/null || true"],
                   sudo: true
  end

  caveats <<~EOS
    Installing this Cask means you have AGREED to the Zulu CCK Terms of Use at

      https://www.azul.com/products/zulu-and-zulu-enterprise/zulu-cck-terms-of-use/
  EOS
end
