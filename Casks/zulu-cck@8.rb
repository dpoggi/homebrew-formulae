cask 'zulu-cck@8' do
  version '1.8.0_163,8.0.0.4'
  sha256 '9f69fcec07b915ace5d0ccaea164b0a3492ac7dceed7f42224c23098ff0613e0'

  # cdn.azul.com was verified as official when first introduced to the cask
  url "https://cdn.azul.com/zcck/bin/zcck#{version.after_comma}-macosx_x64.sh",
      referer: 'https://www.azul.com/products/zulu-and-zulu-enterprise/cck-downloads/mac-os-x/'
  name 'Commercial Compatibility Kit for Zulu 8'
  homepage 'https://zulu.org/developer-resources/commercial-compatibility/'

  depends_on cask: 'zulu@8'
  container type: :naked

  postflight do
    installer_path = staged_path.join("zcck#{version.after_comma}-macosx_x64.sh")
    system_command '/bin/sh',
                   args: ['-c', "tail -n \"+$(awk '/^__ARCHIVE_START__/ { print NR + 1; exit 0; }' \"#{installer_path}\")\" \"#{installer_path}\" | tar xf - -C \"#{staged_path}\""]

    system_command '/bin/mkdir',
                   args: ['-p', "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/etc"],
                   sudo: true
    Dir.glob(staged_path.join('license', '*')) do |license|
      system_command '/bin/ln',
                     args: ['-nsf', license, "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/etc/#{File.basename(license)}"],
                     sudo: true
    end

    system_command '/bin/mkdir',
                   args: ['-p', "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/jre/lib/fonts"],
                   sudo: true
    Dir.glob(staged_path.join('fonts', '*')) do |font|
      system_command '/bin/ln',
                     args: ['-nsf', font, "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/jre/lib/fonts/#{File.basename(font)}"],
                     sudo: true
    end
  end

  uninstall_postflight do
    Dir.glob(staged_path.join('license', '*')) do |license|
      system_command '/bin/rm',
                     args: ['-f', "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/etc/#{File.basename(license)}"],
                     sudo: true
    end
    system_command '/bin/sh',
                   args: ['-c', "rmdir /Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/etc 2>/dev/null || true"],
                   sudo: true

    Dir.glob(staged_path.join('fonts', '*')) do |font|
      system_command '/bin/rm',
                     args: ['-f', "/Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/jre/lib/fonts/#{File.basename(font)}"],
                     sudo: true
    end
    system_command '/bin/sh',
                   args: ['-c', "rmdir /Library/Java/JavaVirtualMachines/zulu#{version.before_comma}.jdk/Contents/Home/jre/lib/fonts 2>/dev/null || true"],
                   sudo: true
  end

  caveats <<~EOS
    Installing this Cask means you have AGREED to the Zulu CCK Terms of Use at

      https://www.azul.com/products/zulu-and-zulu-enterprise/zulu-cck-terms-of-use/
  EOS
end
