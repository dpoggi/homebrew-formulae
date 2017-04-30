cask 'zulu-8-cek' do
  version '1.8.0_131'
  sha256 '8021a28b8cac41b44f1421fd210a0a0822fcaf88d62d2e70a35b2ff628a8675a'

  url "http://www.azulsystems.com/sites/default/files/images/ZuluJCEPolicies.zip"
  name 'Azul Zulu Cryptography Extension Kit for Java SE 8'
  homepage 'http://www.azulsystems.com/products/zulu/cryptographic-extension-kit'

  depends_on cask: 'zulu-8'

  stage_only true

  postflight do
    system_command '/bin/chmod',
                   args: ['755', staged_path/'ZuluJCEPolicies']
    system_command '/bin/sh',
                   args: ['-c', "chmod 644 #{staged_path}/ZuluJCEPolicies/*"]

    system_command '/bin/cp',
                   args: ['-f', '--', staged_path/'ZuluJCEPolicies/local_policy.jar', "/Library/Java/JavaVirtualMachines/zulu#{version}.jdk/Contents/Home/jre/lib/security/local_policy.jar"],
                   sudo: true
    system_command '/usr/sbin/chown',
                   args: ['root:wheel', "/Library/Java/JavaVirtualMachines/zulu#{version}.jdk/Contents/Home/jre/lib/security/local_policy.jar"],
                   sudo: true

    system_command '/bin/cp',
                   args: ['-f', '--', staged_path/'ZuluJCEPolicies/US_export_policy.jar', "/Library/Java/JavaVirtualMachines/zulu#{version}.jdk/Contents/Home/jre/lib/security/US_export_policy.jar"],
                   sudo: true
    system_command '/usr/sbin/chown',
                   args: ['root:wheel', "/Library/Java/JavaVirtualMachines/zulu#{version}.jdk/Contents/Home/jre/lib/security/US_export_policy.jar"],
                   sudo: true
  end
end
