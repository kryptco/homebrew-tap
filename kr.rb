class Kr < Formula
  desc "Krypton command-line client, daemon, and SSH integration"
  homepage "https://krypt.co"

  stable do
	  url "https://github.com/kryptco/kr.git", :tag => "2.4.0"
  end

  bottle do
    rebuild 1
    root_url "https://github.com/kryptco/bottles/raw/master"
    cellar :any_skip_relocation
    sha256 "727e433b4bd74ed28aea0b6381a18aae739db82d3dc31bf803ff73d2776609af" => :el_capitan
    sha256 "1ac6adf8c46058c1e998b168585f979316d54938fe0b094ae19624bd2ba7b5b6" => :sierra
    sha256 "069b9c3e6b481e74bf6458bfc974fe330ff82e36c2c8383c04be420871fd9803" => :high_sierra
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
  #depends_on "python@2" => :build # to fetch emscripten binaryen port
  depends_on "libsodium" => :build # to fetch emscripten binaryen port
  depends_on :xcode => :build if MacOS.version >= "10.12"

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"

    dir = buildpath/"src/github.com/kryptco/kr"
    dir.install buildpath.children

	system "mkdir", "-p", ENV["HOME"]

	system "emcc"
	#system "sed", "-i", "", "/^BINARYEN_ROOT/d", ENV["HOME"] + "/.emscripten"
	system "sed", "-i", "-e", "s/^BINARYEN_ROOT.*/BINARYEN_ROOT = \\'\\/usr\\/local\\/opt\\/binaryen\\'/", ENV["HOME"] + "/.emscripten"
	system "sed", "-i", "", "/^LLVM_ROOT/d", ENV["HOME"] + "/.emscripten"
	system "sh", "-c", "echo LLVM_ROOT = \\'/usr/local/opt/emscripten/libexec/llvm/bin\\' >> #{ENV["HOME"]}/.emscripten"
	system "sed", "-i", "-e", "s/^NODE_JS.*/NODE_JS = \\'\\/usr\\/local\\/bin\\/node\\'/", ENV["HOME"] + "/.emscripten"
	system "cat", ENV["HOME"] + "/.emscripten"
	system "ls", "/usr/local/opt/emscripten/libexec/llvm/bin"
	
	#system "sh", "-c", "
	#curl -O https://s3.amazonaws.com/mozilla-games/emscripten/releases/emsdk-portable.tar.gz &&
	#tar -xzf emsdk-portable.tar.gz &&
	#ls &&
	#source emsdk-portable/emsdk_env.sh &&
	#emsdk update &&
	#emsdk install sdk-incoming-64bit &&
	#emsdk activate sdk-incoming-64bit
	#"

	ENV["PATH"] = ENV["HOME"] + "/.cargo/bin" + ":" + ENV["PATH"]

	#system "touch", ENV["HOME"] + "/.profile"
	system "rustup-init", "-y"
	system "rustup", "target", "add", "wasm32-unknown-emscripten"

	system "cargo", "install", "cargo-web"

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
