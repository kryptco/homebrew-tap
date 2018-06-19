class Kr < Formula
  desc "Krypton command-line client, daemon, and SSH integration"
  homepage "https://krypt.co"

  stable do
	  url "https://github.com/kryptco/kr.git", :tag => "2.4.9"
  end

  bottle do
    rebuild 2
    root_url "https://github.com/kryptco/bottles/raw/master"
    cellar :any_skip_relocation
    sha256 "dc00a3550dc013fefadbfe5828d7baaec7a8f5036716bdaf00382d957a611481" => :el_capitan
    sha256 "423afad5e4c3678882ccce26e75dc7d0e576e1bb023e60172a99bc061e4eeeba" => :sierra
    sha256 "2077aefe22b829d307dc6047050fa569bc167f1deadfa658d168cb51314dadef" => :high_sierra
    sha256 "e6ff6b30d13455eaf51263b79c50ef75340155f074c83b08832f3d93cda9ecc7" => :mojave
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
