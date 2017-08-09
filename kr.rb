class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "2.2.7"

  devel do
	  url "https://github.com/kryptco/kr.git", :tag => "2.2.7"
  end

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "c24d51df5cb1a775ed5e7250a2d59f953ae243e0956134092bad68008f47e9bc" => :yosemite
	sha256 "fe4d321c85e81d3d40e677b049ef4deff6653155935547360993b9f14e2c80dd" => :el_capitan
	sha256 "5c801201f7e718d7868189586da236ed2d853520f9447e1d3ab96e70976f125e" => :sierra
	sha256 "5c801201f7e718d7868189586da236ed2d853520f9447e1d3ab96e70976f125e" => :high_sierra
  end

  depends_on "rust" => :build
  depends_on "go" => :build
  depends_on "pkg-config" => :build

  option "with-no-ssh-config", "DEPRECATED -- export KR_SKIP_SSH_CONFIG=1 to prevent kr from changing ~/.ssh/config"

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
