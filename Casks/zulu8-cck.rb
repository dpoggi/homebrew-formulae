cask 'zulu8-cck' do
  version '8.0.0.4,1.8.0_131'
  sha256 '9f69fcec07b915ace5d0ccaea164b0a3492ac7dceed7f42224c23098ff0613e0'

  url "https://cdn.azul.com/zcck/bin/zcck#{version.before_comma}-macosx_x64.sh",
      referer: 'https://www.azul.com/products/zulu/cck-downloads/mac-os-x/'
  name 'Azul Zulu Commercial Compatibility Kit for Java SE 8'
  homepage 'https://www.azul.com/products/zulu/cck-downloads/'

  depends_on cask: 'zulu8'

  container type: :naked

  postflight do
    IO.write staged_path/'install_cck.tcl', <<-EOS.undent
      set timeout -1

      spawn -noecho /bin/sh #{staged_path}/zcck#{version.before_comma}-macosx_x64.sh

      expect "patch:"
      send "/Library/Java/JavaVirtualMachines/zulu#{version.after_comma}.jdk/Contents/Home\\r"

      expect eof
    EOS

    system_command '/usr/bin/expect',
                   args: [staged_path/'install_cck.tcl'],
                   sudo: true
  end
end
