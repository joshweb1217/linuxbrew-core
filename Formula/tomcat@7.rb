class TomcatAT7 < Formula
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.91/bin/apache-tomcat-7.0.91.tar.gz"
  mirror "https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.91/bin/apache-tomcat-7.0.91.tar.gz"
  sha256 "0008931e39c234522572dd3c023e267a46b35e7c979edbe6838d34368f95cb08"

  bottle :unneeded

  keg_only :versioned_formula

  option "with-fulldocs", "Install full documentation locally"

  depends_on :java

  # Keep log folders
  skip_clean "libexec"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.91/bin/apache-tomcat-7.0.91-fulldocs.tar.gz"
    sha256 "0eadac93d16bd7512a64a84f29e631784d3e7c23287315d1fb166bd1ff44e418"
  end

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w[NOTICE LICENSE RELEASE-NOTES RUNNING.txt]
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (pkgshare/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end

  test do
    ENV["CATALINA_BASE"] = testpath
    cp_r Dir["#{libexec}/*"], testpath
    rm Dir["#{libexec}/logs/*"]

    pid = fork do
      exec bin/"catalina", "start"
    end
    sleep 3
    begin
      system bin/"catalina", "stop"
    ensure
      Process.wait pid
    end
    assert_predicate testpath/"logs/catalina.out", :exist?
  end
end
