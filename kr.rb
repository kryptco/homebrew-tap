class Kr < Formula
  desc "Krypton command-line client, daemon, and SSH integration"
  homepage "https://krypt.co"

  stable do
	  url "https://github.com/kryptco/kr.git", :tag => "2.4.4"
  end

  bottle do
    rebuild 2
    root_url "https://github.com/kryptco/bottles/raw/master"
    cellar :any_skip_relocation
    sha256 "e8b39de506c3ec6bb09acb517cc5b9c613b87cdd90d444b7be923ee0342a40b8" => :el_capitan
    sha256 "ee22bdf8256a6ede8c047d71a4c2b410df9523eb7a310b3b41190a2ce1127f13" => :sierra
    sha256 "3401c4e4ea1e420815d7b88b0c7cb7e1653c20bd01c022652b700e807dcfc103" => :high_sierra
  end

  head do
    url "https://github.com/kryptco/kr.git"
  end

  option "with-no-ssh-config", "DEPRECATED -- export KR_SKIP_SSH_CONFIG=1 to prevent kr from changing ~/.ssh/config"

  depends_on "rust" => :build
  depends_on "rustup" => :build
  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on "emscripten" => :build
  depends_on "binaryen" => :build
  depends_on "libsodium" => :build
  depends_on "rsync" => :build
  depends_on :xcode => :build if MacOS.version >= "10.12"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"

    dir = buildpath/"src/github.com/kryptco/kr"
    dir.install buildpath.children

	system "mkdir", "-p", ENV["HOME"]

        system "emcc" # run emcc to create ~/.emscripten
	system "sed", "-i", "-e", "s/^BINARYEN_ROOT.*/BINARYEN_ROOT = \\'\\/usr\\/local\\/opt\\/binaryen\\'/", ENV["HOME"] + "/.emscripten"
	system "sed", "-i", "", "/^LLVM_ROOT/d", ENV["HOME"] + "/.emscripten"
	system "sh", "-c", "echo LLVM_ROOT = \\'/usr/local/opt/emscripten/libexec/llvm/bin\\' >> #{ENV["HOME"]}/.emscripten"
	system "sed", "-i", "-e", "s/^NODE_JS.*/NODE_JS = \\'\\/usr\\/local\\/bin\\/node\\'/", ENV["HOME"] + "/.emscripten"

	ENV["PATH"] = ENV["HOME"] + "/.cargo/bin" + ":" + ENV["PATH"]

	system "rustup-init", "-y"
	system "rustup", "target", "add", "wasm32-unknown-emscripten"

	system "cargo", "install", "--debug", "--version=0.6.10", "cargo-web"

    cd "src/github.com/kryptco/kr" do
      old_prefix = ENV["PREFIX"]
      ENV["PREFIX"] = prefix
      system "make", "install"
      ENV["PREFIX"] = old_prefix
    end
  end

  def caveats
    "kr is now installed! Run `kr pair` to pair with the Krypton app."
  end

  test do
    system "which kr && which krd"
  end
end
