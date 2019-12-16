class Automake < Formula
  desc "Tool for generating GNU Standards-compliant Makefiles"
  homepage "https://www.gnu.org/software/automake/"
  url "https://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.xz"
  mirror "https://ftpmirror.gnu.org/automake/automake-1.16.1.tar.xz"
  sha256 "5d05bb38a23fd3312b10aea93840feec685bdf4a41146e78882848165d3ae921"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "5f5e0528293a5f6d2ec5c686d5408f8b48489e8b1cfbcb3ebaab844a241d3565" => :catalina
    sha256 "0a359c2385d0673ce1ab3cdaf39dd22af191f7b74732105ca5751e08a334e061" => :mojave
    sha256 "fb32c065aaf91661380af32ed301edcf209ba453635c79ca945353b67e54af10" => :high_sierra
    sha256 "fb32c065aaf91661380af32ed301edcf209ba453635c79ca945353b67e54af10" => :sierra
    sha256 "d552844779f0dc4062f27203f7facfbd74c9d1780724ac76a86791e401aa73bd" => :el_capitan
    sha256 "98a28717930814875958c8b63e72acd2e6aeaa99caefe89ccd604fd7a17a586a" => :x86_64_linux
  end

  depends_on "autoconf"

  # https://lists.gnu.org/archive/html/bug-automake/2018-04/msg00002.html
  # https://git.savannah.gnu.org/cgit/automake.git/commit/?id=a348d830659fffd2cfc42994524783b07e69b4b5
  # Remove this when applying any future 1.16.2 update.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/6c632516/automake/python.diff"
    sha256 "c048ce853eef073a5dfce34fcf9af786e8525e384e01dbbf4e6066623985d4c7"
  end

  def install
    ENV["PERL"] = "/usr/bin/perl" if OS.mac?

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Our aclocal must go first. See:
    # https://github.com/Homebrew/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<~EOS
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      int main() { return 0; }
    EOS
    (testpath/"configure.ac").write <<~EOS
      AC_INIT(test, 1.0)
      AM_INIT_AUTOMAKE
      AC_PROG_CC
      AC_CONFIG_FILES(Makefile)
      AC_OUTPUT
    EOS
    (testpath/"Makefile.am").write <<~EOS
      bin_PROGRAMS = test
      test_SOURCES = test.c
    EOS
    system bin/"aclocal"
    system bin/"automake", "--add-missing", "--foreign"
    system "autoconf"
    system "./configure"
    system "make"
    system "./test"
  end
end
