class Flickcurl < Formula
  desc "Library for the Flickr API"
  homepage "http://librdf.org/flickcurl/"
  url "http://download.dajobe.org/flickcurl/flickcurl-1.26.tar.gz"
  sha256 "ff42a36c7c1c7d368246f6bc9b7d792ed298348e5f0f5d432e49f6803562f5a3"

  bottle do
    sha256 cellar: :any, arm64_big_sur: "49065801b7dfe7880206948a41c58ae5f190b50e3acbbe7d14ff24d29a30db0c"
    sha256 cellar: :any, big_sur:       "90c210da66773047b62e3f5922382d97a7da8d4b17b178b25149a07d910c6f4a"
    sha256 cellar: :any, catalina:      "6188ec0f80d29fb32f2f6bb08ee8eb3fd7aa66cd1e3a4f8c4a138f33a5b5271a"
    sha256 cellar: :any, mojave:        "731f6f4a68337a3aef6448ec67a0dab1e2cc7eee3d8a827582f398578fc2bc3a"
    sha256 cellar: :any, high_sierra:   "6cc2fc33f360e706671c33d25059784f934f7371142c54977bb50a1d5b47d6e8"
    sha256 cellar: :any, sierra:        "ddffd36ee6ab7c4cfd0edba1be9aa488ed38d1ee66a99c2e2445bf4d21cd0c00"
    sha256 cellar: :any, el_capitan:    "01886ddb800167eed18495d780baa81bac793243a54d452ad9a34a06e876e4d2"
    sha256 cellar: :any, yosemite:      "64c7a8f7d2bcc90063f926724fd1bd9277f783f3aca3c83e53684222f3d1d1c3"
    sha256 cellar: :any, x86_64_linux:  "6c86b32a14f619047b098012b44d8499b0e067a0e702c36140b71ceb2314562d"
  end

  depends_on "pkg-config" => :build

  uses_from_macos "curl"
  uses_from_macos "libxml2"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/flickcurl -h 2>&1", 1)
    assert_match "flickcurl: Configuration file", output
  end
end
