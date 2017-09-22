cask 'zulu-cek@7' do
  version '1.7.0_154'
  sha256 '8021a28b8cac41b44f1421fd210a0a0822fcaf88d62d2e70a35b2ff628a8675a'

  url 'https://cdn.azul.com/zcek/bin/ZuluJCEPolicies.zip'
  name 'Cryptography Extension Kit for Zulu 7'
  homepage 'https://www.azul.com/products/zulu-and-zulu-enterprise/zulu-cryptography-extension-kit/'

  depends_on cask: 'zulu@7'

  stage_only true

  postflight do
    system_command '/usr/bin/install',
                   args: ['-p', '-m', '0644', '-o', 'root', '-g', 'wheel', '--', staged_path.join('ZuluJCEPolicies', 'local_policy.jar'), "/Library/Java/JavaVirtualMachines/zulu#{version}.jdk/Contents/Home/jre/lib/security/local_policy.jar"],
                   sudo: true
    system_command '/usr/bin/install',
                   args: ['-p', '-m', '0644', '-o', 'root', '-g', 'wheel', '--', staged_path.join('ZuluJCEPolicies', 'US_export_policy.jar'), "/Library/Java/JavaVirtualMachines/zulu#{version}.jdk/Contents/Home/jre/lib/security/US_export_policy.jar"],
                   sudo: true
  end

  caveats <<-EOS.undent
    By installing this Cask, you certify that you reside in a jurisdiction that
    does NOT restrict the importation or use of the strong cryptography software
    contained herein.
  EOS
end
