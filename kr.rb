class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "2.2.6"

  devel do
	  url "https://github.com/kryptco/kr.git", :tag => "2.2.7"
  end

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "c22ad8d1d050b75c8ebace007e598dc44dd868f3a9a1d328d0c611355b629703" => :yosemite
	sha256 "d2dded5de0fa8f25e7e446d6a1e543af7cba8ea946467232784144cb951e6d8f" => :el_capitan
	sha256 "0683c973a3339f73012105bf1638d5f5cedfb8107b0589c281c88d0b170b248f" => :sierra
	sha256 "0683c973a3339f73012105bf1638d5f5cedfb8107b0589c281c88d0b170b248f" => :high_sierra
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
