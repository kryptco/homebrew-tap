class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "2.2.5"

  devel do
	  url "https://github.com/kryptco/kr.git", :tag => "2.2.5"
  end

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "3dfe2978a8772b5a3b02187e6694163708012cd4cc4e953cc056f4ab0e49f1bc" => :yosemite
	sha256 "e93d8eda7c573a543b1b08f7d69580d52bb0ce4fe6b2825449a1e471c3f5e106" => :el_capitan
	sha256 "01b30890f7b6f653dbd3f5a9c79030b35b2d396d370a2fca99d8801e2dd2cd7f" => :sierra
	sha256 "01b30890f7b6f653dbd3f5a9c79030b35b2d396d370a2fca99d8801e2dd2cd7f" => :high_sierra
  end

  depends_on "rust" => :build
  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on "libsodium"

  option "with-no-ssh-config", "Do not modify ~/.ssh/config"

  def install
	  ENV["GOPATH"] = buildpath
	  ENV["GOOS"] = "darwin"
	  ENV["GOARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"

	  dir = buildpath/"src/github.com/kryptco/kr"
	  dir.install buildpath.children

	  cd "src/github.com/kryptco/kr/kr" do
		  system "go", "build", "-ldflags", "-s", "-o", bin/"kr"
	  end
	  cd "src/github.com/kryptco/kr/krd/main" do
		  system "go", "build", "-ldflags", "-s", "-o", bin/"krd"
	  end
	  cd "src/github.com/kryptco/kr/krssh" do
		  system "go", "build", "-ldflags", "-s", "-o", bin/"krssh"
	  end
	  cd "src/github.com/kryptco/kr/krgpg" do
		  system "go", "build", "-ldflags", "-s", "-o", bin/"krgpg"
	  end
	  cd "src/github.com/kryptco/kr/pkcs11shim" do
		  system "make"
	  end
	  lib.install "src/github.com/kryptco/kr/pkcs11shim/target/release/kr-pkcs11.so"

	  (share/"kr").install "src/github.com/kryptco/kr/share/kr.png"
	  (share/"kr").install "src/github.com/kryptco/kr/share/co.krypt.krd.plist"

  end
  
  def post_install
  end

   def caveats
	   return "kr is now installed! Run `kr pair` to pair with the Kryptonite app."
   end

end
