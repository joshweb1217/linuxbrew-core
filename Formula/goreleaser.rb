class Goreleaser < Formula
  desc "Deliver Go binaries as fast and easily as possible"
  homepage "https://goreleaser.com/"
  url "https://github.com/goreleaser/goreleaser.git",
      tag:      "v0.162.1",
      revision: "e4e242f573aa6337a6d7ac70c0ce29121e9214e7"
  license "MIT"
  head "https://github.com/goreleaser/goreleaser.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "6c41c999f6ac36368f6f044d37ebc01d4f0ad100718f028001f4e3b399cb61e2"
    sha256 cellar: :any_skip_relocation, big_sur:       "062139fc022fd46bf8bc50e06b845b172bd49be7652d94f3893d3abcfe028838"
    sha256 cellar: :any_skip_relocation, catalina:      "e9a0de6dc19b0f09fdf3d78429f15c6905a236c40263e5151aafd7331c63e148"
    sha256 cellar: :any_skip_relocation, mojave:        "ab544c918c4ae87d9e9d23467797ac3d8d24da41c818682792f1b9146b50ef40"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fcf6602ae7e833cb47ac0677f40d5b5bd31bf3f778d28cc2896d46e7c22809d2"
  end

  depends_on "go" => :build

  def install
    system "go", "build", "-ldflags",
             "-s -w -X main.version=#{version} -X main.commit=#{Utils.git_head} -X main.builtBy=homebrew",
             *std_go_args

    # Install shell completions
    output = Utils.safe_popen_read("#{bin}/goreleaser", "completion", "bash")
    (bash_completion/"goreleaser").write output

    output = Utils.safe_popen_read("#{bin}/goreleaser", "completion", "zsh")
    (zsh_completion/"_goreleaser").write output

    output = Utils.safe_popen_read("#{bin}/goreleaser", "completion", "fish")
    (fish_completion/"goreleaser.fish").write output
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goreleaser -v 2>&1")
    assert_match "config created", shell_output("#{bin}/goreleaser init --config=.goreleaser.yml 2>&1")
    assert_predicate testpath/".goreleaser.yml", :exist?
  end
end
