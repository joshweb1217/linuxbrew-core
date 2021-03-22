class Cppcheck < Formula
  desc "Static analysis of C and C++ code"
  homepage "https://sourceforge.net/projects/cppcheck/"
  url "https://github.com/danmar/cppcheck/archive/2.4.tar.gz"
  sha256 "d1ac6a1eaf24f2f54df5a164c7e37d1e0624cc094a4622e226a73b53ede1eeb8"
  license "GPL-3.0-or-later"
  head "https://github.com/danmar/cppcheck.git"

  bottle do
    sha256 arm64_big_sur: "f15d1c5b9ba3cb0a413a8f7d23182d0a81ddbb444d4d7dcb1ff940799965e32e"
    sha256 big_sur:       "755d0e70d7541cbfea47ca5792499e3f140d3c7a0d2796430829210497057bed"
    sha256 catalina:      "8f677e37fa53f6432cd763370375781986a6d97706d3a3c50561e465b70a0287"
    sha256 mojave:        "316ad7e3082e78e9316b943c7adcce849cd02b0e0b0096e0ea8faf4b8eccf6aa"
    sha256 x86_64_linux:  "6c3a0e4f014e992e2c8f0ccd257a0087136d842cfae2fd7baa35b185c12c67bf"
  end

  depends_on "python@3.9" => :test
  depends_on "pcre"

  def install
    ENV.cxx11

    system "make", "HAVE_RULES=yes", "FILESDIR=#{prefix}/cfg"

    # FILESDIR is relative to the prefix for install, don't add #{prefix}.
    system "make", "DESTDIR=#{prefix}", "BIN=#{bin}", "FILESDIR=/cfg", "install"

    # Move the python addons to the cppcheck pkgshare folder
    (pkgshare/"addons").install Dir.glob("addons/*.py")
  end

  test do
    # Execution test with an input .cpp file
    test_cpp_file = testpath/"test.cpp"
    test_cpp_file.write <<~EOS
      #include <iostream>
      using namespace std;

      int main()
      {
        cout << "Hello World!" << endl;
        return 0;
      }

      class Example
      {
        public:
          int GetNumber() const;
          explicit Example(int initialNumber);
        private:
          int number;
      };

      Example::Example(int initialNumber)
      {
        number = initialNumber;
      }
    EOS
    system "#{bin}/cppcheck", test_cpp_file

    # Test the "out of bounds" check
    test_cpp_file_check = testpath/"testcheck.cpp"
    test_cpp_file_check.write <<~EOS
      int main()
      {
      char a[10];
      a[10] = 0;
      return 0;
      }
    EOS
    output = shell_output("#{bin}/cppcheck #{test_cpp_file_check} 2>&1")
    assert_match "out of bounds", output

    # Test the addon functionality: sampleaddon.py imports the cppcheckdata python
    # module and uses it to parse a cppcheck dump into an OOP structure. We then
    # check the correct number of detected tokens and function names.
    addons_dir = pkgshare/"addons"
    cppcheck_module = "#{name}data"
    expect_token_count = 55
    expect_function_names = "main,GetNumber,Example"
    assert_parse_message = "Error: sampleaddon.py: failed: can't parse the #{name} dump."

    sample_addon_file = testpath/"sampleaddon.py"
    sample_addon_file.write <<~EOS
      #!/usr/bin/env #{Formula["python@3.9"].opt_bin}/python3
      """A simple test addon for #{name}, prints function names and token count"""
      import sys
      from importlib import machinery, util
      # Manually import the '#{cppcheck_module}' module
      spec = machinery.PathFinder().find_spec("#{cppcheck_module}", ["#{addons_dir}"])
      cpp_check_data = util.module_from_spec(spec)
      spec.loader.exec_module(cpp_check_data)

      for arg in sys.argv[1:]:
          # Parse the dump file generated by #{name}
          configKlass = cpp_check_data.parsedump(arg)
          if len(configKlass.configurations) == 0:
              sys.exit("#{assert_parse_message}") # Parse failure
          fConfig = configKlass.configurations[0]
          # Pick and join the function names in a string, separated by ','
          detected_functions = ','.join(fn.name for fn in fConfig.functions)
          detected_token_count = len(fConfig.tokenlist)
          # Print the function names on the first line and the token count on the second
          print("%s\\n%s" %(detected_functions, detected_token_count))
    EOS

    system "#{bin}/cppcheck", "--dump", test_cpp_file
    test_cpp_file_dump = "#{test_cpp_file}.dump"
    assert_predicate testpath/test_cpp_file_dump, :exist?
    output = shell_output(Formula["python@3.9"].opt_bin/"python3 #{sample_addon_file} #{test_cpp_file_dump}")
    assert_match "#{expect_function_names}\n#{expect_token_count}", output
  end
end
