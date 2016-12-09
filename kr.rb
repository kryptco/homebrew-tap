class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "1.0.14"

  #devel do
	  #url "https://github.com/agrinman/kr.git", :tag => "1.0.14"
  #end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "09978002c969a479561c462c63c8b2957b4ec8e1143813db92653eb81be75803" => :yosemite
	sha256 "988190091d584789bb0dc30bd3a67623ffcb53ba423b64345fef131aee256f4e" => :el_capitan
	sha256 "59ceb8d7702cf9f25f02093f38227855f239ed51e885aaa87a631a241d56997c" => :sierra
  end

  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on "libsodium"

  def install
	  ENV["GOPATH"] = buildpath
	  ENV["GOOS"] = "darwin"
	  ENV["GOARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"

	  dir = buildpath/"src/github.com/agrinman/kr"
	  dir.install buildpath.children

	  cd "src/github.com/agrinman/kr/kr" do
		  system "go", "build", "-o", bin/"kr"
	  end
	  cd "src/github.com/agrinman/kr/krd" do
		  system "go", "build", "-o", bin/"krd"
	  end
	  cd "src/github.com/agrinman/kr/pkcs11" do
		  system "make"
	  end
	  lib.install "src/github.com/agrinman/kr/pkcs11/kr-pkcs11.so"

	  (share/"kr").install "src/github.com/agrinman/kr/share/kr.png"
	  (share/"kr").install "src/github.com/agrinman/kr/share/co.krypt.krd.plist"

  end

  def post_install
	  #	add PKCS11Provider to ssh_config if not present
	  system "touch ~/.ssh/config; perl -0777 -ne '/\\n# Added by Kryptonite\\nHost \\*\\n\\tPKCS11Provider \\/usr\\/local\\/lib\\/kr-pkcs11.so/ || exit(1)' ~/.ssh/config || echo \"\\\\n# Added by Kryptonite\\nHost *\\\\n\\\\tPKCS11Provider /usr/local/lib/kr-pkcs11.so\" >> ~/.ssh/config"
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
