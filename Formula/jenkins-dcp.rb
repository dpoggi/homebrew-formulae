class JenkinsDcp < Formula
  desc "Extendable open-source CI server"
  homepage "https://jenkins.io/index.html#stable"
  url "http://mirrors.jenkins.io/war-stable/2.89.4/jenkins.war"
  sha256 "1d893aa30e49a3130e4f90268044dafb34f7c32b573970f2acca8c2c821f9b53"

  bottle :unneeded

  depends_on :java => "1.7+"

  def install
    system "jar", "xvf", "jenkins.war"
    libexec.install "jenkins.war", "WEB-INF/jenkins-cli.jar"
    bin.write_jar_script libexec/"jenkins.war", "jenkins-dcp"
    bin.write_jar_script libexec/"jenkins-cli.jar", "jenkins-dcp-cli"
  end

  def caveats; <<~EOS
    Note: When using launchctl the port will be 28080.
    EOS
  end

  plist_options :manual => "jenkins-dcp"

  def plist; <<~EOS
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
        <string>/usr/bin/java</string>
        <string>-noverify</string>
        <string>-Xms96m</string>
        <string>-Xmx768m</string>
        <string>-XX:+UseG1GC</string>
        <string>-XX:MaxGCPauseMillis=333</string>
        <string>-Dmail.smtp.starttls.enable=true</string>
        <string>-jar</string>
        <string>#{opt_libexec}/jenkins.war</string>
        <string>--httpListenAddress=127.0.0.1</string>
        <string>--httpPort=28080</string>
      </array>
    </dict>
    </plist>
    EOS
  end

  test do
    ENV["JENKINS_HOME"] = testpath
    ENV.append "_JAVA_OPTIONS", "-Djava.io.tmpdir=#{testpath}"

    pid = fork do
      exec "#{bin}/jenkins-dcp"
    end
    sleep 60

    begin
      output = shell_output("curl localhost:8080/")
      assert_match(/Welcome to Jenkins!|Unlock Jenkins|Authentication required/, output)
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
