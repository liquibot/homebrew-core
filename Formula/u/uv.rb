class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.4.5.tar.gz"
  sha256 "8a58f1059d31b1caabd8e90ca51833d4a6894def0b958247a9f50bcfbb02bf08"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "4ac4f3b8d5ec2ef57cc504eac2328bd54361a1841077ebe1e66d664d3e970c4c"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "9e3b44dda980a653a56061664d8fa7a277054144115535ea700a0db9400ec3c9"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "b44edbc74436504a7fc80a94a063bd2221d2ddeeaef900ad7ab4c77c4eb12ba0"
    sha256 cellar: :any_skip_relocation, sonoma:         "a8cf2fd540d54d4e1558beaf94414235d52ad2113b277371a4c80739eed789d0"
    sha256 cellar: :any_skip_relocation, ventura:        "69c0da1d8243533c0c4207f22e696b8e7730fcd7e2e73358a5b8cb31456c76b9"
    sha256 cellar: :any_skip_relocation, monterey:       "eb45aa7cb5cd31c57dbf948fdd43dc61175f51f205291fe6e66de36e2eb70dea"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "386b4ff75fd71dcd66a2888dc9425a7864abf82e14201508262d627d84976e72"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :test
  uses_from_macos "xz"

  on_linux do
    # On macOS, bzip2-sys will use the bundled lib as it cannot find the system or brew lib.
    # We only ship bzip2.pc on Linux which bzip2-sys needs to find library.
    depends_on "bzip2"
  end

  def install
    ENV["UV_COMMIT_HASH"] = ENV["UV_COMMIT_SHORT_HASH"] = tap.user
    ENV["UV_COMMIT_DATE"] = time.strftime("%F")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    assert_match "ruff 0.5.1", shell_output("#{bin}/uvx -q ruff@0.5.1 --version")
  end
end
