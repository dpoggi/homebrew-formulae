class JenkinsDcp < Formula
  desc "Extendable open-source CI server"
  homepage "https://jenkins.io/index.html#stable"
  url "http://mirrors.jenkins.io/war-stable/2.107.1/jenkins.war"
  sha256 "cec74c80190ed1f6ce55d705d2f649ddb2eaf8aba3ae26796152921d46b31280"

  bottle :unneeded

  JAVA_VERSION = "1.8".freeze
  JAVA_OPTS = %w[
    -server
    -Xms512m
    -Xmx1024m
    -XX:+AlwaysPreTouch
    -XX:+UseG1GC
    -XX:+ExplicitGCInvokesConcurrent
    -XX:+ParallelRefProcEnabled
    -XX:+UseStringDeduplication
    -XX:+UnlockExperimentalVMOptions
    -XX:G1NewSizePercent=20
    -Dmail.smtp.starttls.enable=true
  ].freeze

  depends_on :java => JAVA_VERSION

  def install
    system "jar", "xvf", "jenkins.war"
    libexec.install "jenkins.war", "WEB-INF/jenkins-cli.jar"
    bin.write_jar_script libexec/"jenkins.war", "jenkins-dcp", JAVA_OPTS.join(" "), :java_version => JAVA_VERSION
    bin.write_jar_script libexec/"jenkins-cli.jar", "jenkins-dcp-cli", :java_version => JAVA_VERSION
  end

  def post_install
    (var/"jenkins").mkpath
  end

  def caveats; <<~EOS
    You may want to add the following to your .bash_profile:
      export JENKINS_HOME=#{var}/jenkins

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
      <key>EnvironmentVariables</key>
      <dict>
        <key>JENKINS_HOME</key>
        <string>#{var}/jenkins</string>
      </dict>
      <key>ProgramArguments</key>
      <array>
        <string>/usr/libexec/java_home</string>
        <string>-v</string>
        <string>#{JAVA_VERSION}</string>
        <string>--exec</string>
        <string>java</string>
        #{JAVA_OPTS.map { |opt| "<string>#{opt}</string>" }.join("\n    ")}
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
