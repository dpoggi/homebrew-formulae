cask 'zulu-cck@7' do
  version '7.0.0.4,1.7.0_154'
  sha256 '8602d339b2b2384895d2c56abeab55b02931a7943c4a3a7880b6d770d1b07511'

  # cdn.azul.com was verified as official when first introduced to the cask
  url "https://cdn.azul.com/zcck/bin/zcck#{version.before_comma}-macosx_x64.sh",
      referer: 'https://www.azul.com/products/zulu-and-zulu-enterprise/cck-downloads/mac-os-x/'
  name 'Commercial Compatibility Kit for Zulu 7'
  homepage 'https://zulu.org/developer-resources/commercial-compatibility/'

  depends_on cask: 'zulu@7'
  container type: :naked

  postflight do
    script_path = staged_path.join('install_cck.tcl')

    IO.write script_path, <<-EOS.undent
      set timeout -1

      spawn -noecho /bin/sh #{staged_path}/zcck#{version.before_comma}-macosx_x64.sh

      expect "patch:"
      send "/Library/Java/JavaVirtualMachines/zulu#{version.after_comma}.jdk/Contents/Home\\r"

      expect eof
    EOS

    system_command '/usr/bin/expect',
                   args: [script_path],
                   sudo: true
  end

  caveats <<-EOS.undent
    Installing this Cask means you have AGREED to the Zulu CCK Terms of Use at

      https://www.azul.com/products/zulu-and-zulu-enterprise/zulu-cck-terms-of-use/
  EOS
end
