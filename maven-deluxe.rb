class MavenDeluxe < Formula
  desc "Java-based project management... deluxe"
  homepage "https://github.com/jcgay/homebrew-jcgay#maven-deluxe"
  url "https://www.apache.org/dyn/closer.cgi?path=maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz"
  mirror "https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz"
  version "3.3.9-7"
  sha256 "6e3e9c949ab4695a204f74038717aa7b2689b1be94875899ac1b3fe42800ff82"

  bottle :unneeded

  depends_on :java

  conflicts_with "maven", :because => "also installs a 'mvn' executable"
  conflicts_with "mvnvm", :because => "also installs a 'mvn' executable"

  resource "maven-color-1.6.0" do
    url "https://dl.bintray.com/jcgay/maven/com/github/jcgay/maven/color/maven-color-logback/1.6.0/maven-color-logback-1.6.0-bundle.tar.gz"
    sha256 "c6f109712061c55608db0aa45abfe127faf7ea08ca19dd04adae5be2247afc44"
  end

  resource "maven-profiler-2.5" do
    url "https://dl.bintray.com/jcgay/maven/fr/jcgay/maven/maven-profiler/2.5/maven-profiler-2.5-shaded.jar"
    sha256 "9a68b6836a565cddd4ee423f96f0c49a0f11f1f6a7196c0c2572bd8390a17add"
  end

  def install
    # Remove Windows files
    rm_f Dir["bin/*.bat"]

    # Fix permissions on the global settings file
    chmod 0644, "conf/settings.xml"

    libexec.install Dir["*"]

    Pathname.glob("#{libexec}/bin/*") do |file|
      next if file.directory?

      basename = file.basename

      # Leave conf file in libexec. The mvn symlink will be resolved and the conf
      # file will be found relative to it.
      next if basename.to_s == "m2.conf"

      (bin/basename).write_env_script(file, Language::Java.overridable_java_home_env)
    end

    # Remove slf4j-simple
    rm_f Dir[libexec/"lib/slf4j-simple*"]

    resource("maven-color-1.6.0").stage do
      cp_r ".", libexec
    end

    resource("maven-profiler-2.5").stage do
      (libexec/"lib/ext").install Dir["*"]
    end
  end

  test do
    (testpath/"pom.xml").write <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <project xmlns="http://maven.apache.org/POM/4.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
        <modelVersion>4.0.0</modelVersion>

        <groupId>sh.brew</groupId>
        <artifactId>maven-deluxe-test</artifactId>
        <version>1.0.0</version>
        <packaging>jar</packaging>

        <properties>
          <maven.test.skip>true</maven.test.skip>
          <maven.compiler.source>1.6</maven.compiler.source>
          <maven.compiler.target>1.6</maven.compiler.target>
          <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

          <maven-jar-plugin.version>3.0.2</maven-jar-plugin.version>
        </properties>

        <build>
          <finalName>${project.artifactId}</finalName>

          <plugins>
            <plugin>
              <artifactId>maven-jar-plugin</artifactId>
              <version>${maven-jar-plugin.version}</version>
              <configuration>
                <archive>
                  <manifest>
                    <mainClass>sh.brew.MavenDeluxeTest</mainClass>
                    <addDefaultImplementationEntries>true</addDefaultImplementationEntries>
                  </manifest>
                </archive>
              </configuration>
            </plugin>
          </plugins>
        </build>
      </project>
    EOS

    (testpath/"src/main/java/sh/brew/MavenDeluxeTest.java").write <<-EOS.undent
      package sh.brew;

      public final class MavenDeluxeTest {
        public static void main(String[] args) {
          System.out.println("Testing Maven Deluxe with Homebrew!");
        }

        private MavenDeluxeTest() {
        }
      }
    EOS

    system "#{bin}/mvn", "package", "-Duser.home=#{testpath}"

    system "java", "-jar", "target/maven-deluxe-test.jar"
  end
end
