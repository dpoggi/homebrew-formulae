cask 'zulu7-cck' do
  version '7.0.0.4,7.0_141'
  sha256 '8602d339b2b2384895d2c56abeab55b02931a7943c4a3a7880b6d770d1b07511'

  url "https://cdn.azul.com/zcck/bin/zcck#{version.before_comma}-macosx_x64.sh",
      referer: 'https://www.azul.com/products/zulu/cck-downloads/mac-os-x/'
  name 'Azul Zulu Commercial Compatibility Kit for Java SE 7'
  homepage 'https://www.azul.com/products/zulu/cck-downloads/'

  depends_on cask: 'zulu7'

  container type: :naked

  postflight do
    IO.write staged_path/'install_cck.tcl', <<-EOS.undent
      set timeout -1

      spawn -noecho /bin/sh #{staged_path}/zcck#{version.before_comma}-macosx_x64.sh

      expect "patch:"
      send "/Library/Java/JavaVirtualMachines/zulu1.#{version.after_comma}.jdk/Contents/Home\\r"

      expect eof
    EOS

    system_command '/usr/bin/expect',
                   args: [staged_path/'install_cck.tcl'],
                   sudo: true
  end
end
