class Cgns < Formula
  desc "CFD General Notation System"
  homepage "http://cgns.org/"
  url "https://github.com/CGNS/CGNS/archive/v4.1.2.tar.gz"
  sha256 "951653956f509b8a64040f1440c77f5ee0e6e2bf0a9eef1248d370f60a400050"
  license "BSD-3-Clause"
  revision 1 unless OS.mac?
  head "https://github.com/CGNS/CGNS.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "abc3326bddbf58509b5ffb3834d68836ad803abf83f9958ae6a012870e7e9f85"
    sha256 cellar: :any,                 big_sur:       "e2e5eb665f0f5c94c7782f0aed3708124705792ff5a7adf945a537369db6d724"
    sha256 cellar: :any,                 catalina:      "4371c695cad1aa0bccbaaf0deccb9a8f5ddf7271dcbbddf6307b8d0bc254cec5"
    sha256 cellar: :any,                 mojave:        "d9904ca7c839a5d0421b99ba784e98fec047971de47efa5d3cc00725cd892e26"
    sha256 cellar: :any,                 high_sierra:   "8bfeb33c22f79c998b31fea6aafc60aecf2edf18ea754799c67c012d90555ec9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8c443c0a02320b5eddd705cf527525a97d0c6d52a68dfe3956970afb3dcc536c"
  end

  depends_on "cmake" => :build
  depends_on "gcc" # for gfortran
  depends_on "hdf5"
  depends_on "szip"

  uses_from_macos "zlib"

  def install
    args = std_cmake_args + %w[
      -DCGNS_ENABLE_64BIT=YES
      -DCGNS_ENABLE_FORTRAN=YES
      -DCGNS_ENABLE_HDF5=YES
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # Avoid references to Homebrew shims
    os = OS.mac? ? "mac" : "linux"
    cc = OS.mac? ? "clang" : "gcc-5"
    inreplace include/"cgnsBuild.defs", HOMEBREW_LIBRARY/"Homebrew/shims/#{os}/super/#{cc}", "/usr/bin/#{cc}"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include "cgnslib.h"
      int main(int argc, char *argv[])
      {
        int filetype = CG_FILE_NONE;
        if (cg_is_cgns(argv[0], &filetype) != CG_ERROR)
          return 1;
        return 0;
      }
    EOS
    system Formula["hdf5"].opt_prefix/"bin/h5cc", testpath/"test.c", "-L#{opt_lib}", "-lcgns",
                                                  *("-Wl,-rpath=#{Formula["szip"].opt_lib}" unless OS.mac?),
                                                  *("-Wl,-rpath=#{lib}" unless OS.mac?)
    system "./a.out"
  end
end
