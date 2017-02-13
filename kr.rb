class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "1.0.14"

  devel do
	  url "https://github.com/kryptco/kr.git", :tag => "1.0.15"
  end

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "cf2da43450aea8ada00f64ff96ed36e9c5b67cf81bbd60779db60f1bfa879ac3" => :yosemite
	sha256 "5d532e1c3ee22fe344db4ca56e0d6fbc12c031ef5a2415554b03671b65740765" => :el_capitan
	sha256 "36372e113bd3966c728efe7a3e11448b2405f77d65afaa5d7ef8eb16d5cfd008" => :sierra
  end

  depends_on "rust" => :build
  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on "libsodium"

  def install
	  ENV["GOPATH"] = buildpath
	  ENV["GOOS"] = "darwin"
	  ENV["GOARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"

	  dir = buildpath/"src/github.com/kryptco/kr"
	  dir.install buildpath.children

	  cd "src/github.com/kryptco/kr/kr" do
		  system "go", "build", "-o", bin/"kr"
	  end
	  cd "src/github.com/kryptco/kr/krd" do
		  system "go", "build", "-o", bin/"krd"
	  end
	  cd "src/github.com/kryptco/kr/krssh" do
		  system "go", "build", "-o", bin/"krssh"
	  end
	  cd "src/github.com/kryptco/kr/pkcs11shim" do
		  system "make"
	  end
	  lib.install "src/github.com/kryptco/kr/pkcs11shim/target/release/kr-pkcs11.so"
	  cd "src/github.com/kryptco/kr/loggingdylib" do
		  system "make"
	  end
	  lib.install "src/github.com/kryptco/kr/loggingdylib/target/release/libkrlogging.dylib"

	  (share/"kr").install "src/github.com/kryptco/kr/share/kr.png"
	  (share/"kr").install "src/github.com/kryptco/kr/share/co.krypt.krd.plist"

  end

  def post_install
	  #	add PKCS11Provider to ssh_config if not present
	  system "touch ~/.ssh/config; perl -0777 -ne '/\\n# Added by Kryptonite\\nHost \\*\\n\\tPKCS11Provider \\/usr\\/local\\/lib\\/kr-pkcs11.so\\n\\tProxyCommand `find \\/usr\\/local\\/bin\\/krssh 2>\\/dev\\/null \\|\\| which nc` %h %p/ || exit(1)' ~/.ssh/config || echo \"\\\\n# Added by Kryptonite\\nHost *\\\\n\\\\tPKCS11Provider /usr/local/lib/kr-pkcs11.so\\\\n\\\\tProxyCommand \\`find /usr/local/bin/krssh 2>/dev/null || which nc\\` %h %p\" >> ~/.ssh/config"
	  system "mkdir -p ~/Library/LaunchAgents; cp /usr/local/share/kr/co.krypt.krd.plist ~/Library/LaunchAgents"
	  system "launchctl unload ~/Library/LaunchAgents/co.krypt.krd.plist || true"
	  system "launchctl load ~/Library/LaunchAgents/co.krypt.krd.plist"
  end

   def caveats; <<-EOS.undent
	   kr is now up and running! Type "kr pair" to begin using it.

	   kr can be uninstalled by running "kr uninstall"
  EOS
  end

end
