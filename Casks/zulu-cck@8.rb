cask 'zulu-cck@8' do
  version '1.8.0_312,8.0.0.8'
  sha256 '97a4b7c2c3c44d5b6add85c22d4d956bf40b34bd3c87567db29647c884a2f4ad'

  url "https://cdn.azul.com/zcck/bin/zcck#{version.after_comma}-macosx_x64.sh",
      referer: 'https://www.azul.com/products/components/commercial-compatibility-kit/'
  name 'Commercial Compatibility Kit for Zulu OpenJDK 8'
  homepage 'https://www.azul.com/products/components/commercial-compatibility-kit/'

  depends_on cask: 'zulu@8'
  container type: :naked

  java_home = Pathname.new("/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home")

  postflight do
    installer_path = staged_path.join("zcck#{version.after_comma}-macosx_x64.sh")
    installer_extract_script = <<~EOS
      START="$(
        awk '/^__ARCHIVE_START__/ { print NR + 1; exit }' '#{installer_path}'
      )"
      tail -n "+${START}" '#{installer_path}' | tar xf - -C '#{staged_path}'
    EOS

    system_command '/bin/sh',
                   args: ['-c', installer_extract_script]

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
    Dir.glob(staged_path.join('license', '*')) do |license|
      system_command '/bin/rm',
                     args: ['-f', java_home.join('etc', File.basename(license))],
                     sudo: true
    end

    system_command '/bin/sh',
                   args: ['-c', "rmdir '#{java_home.join('etc')}' 2>/dev/null || :"],
                   sudo: true

    Dir.glob(staged_path.join('fonts', '*')) do |font|
      system_command '/bin/rm',
                     args: ['-f', java_home.join('jre', 'lib', 'fonts', File.basename(font))],
                     sudo: true
    end

    system_command '/bin/sh',
                   args: ['-c', "rmdir '#{java_home.join('jre', 'lib', 'fonts')}' 2>/dev/null || :"],
                   sudo: true
  end

  caveats <<~EOS
    Installing this Cask means you have AGREED to the Zulu CCK Terms of Use at

      https://www.azul.com/products/core/cck-terms-of-use/
  EOS
end
