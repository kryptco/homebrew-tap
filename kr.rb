require "language/go"
class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  version "1.0.2"
  head "https://github.com/agrinman/kr.git"
  url "-"

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
    sha256 "47fa1dddfa1073d06b8dbb34c5a9b02cfb22c88931efa81bc74269758d9e7073" => :el_capitan
	sha256 "b74b84427d36dca90dc57ca6e5f428d051fe4fa9196e2f8b780c9c5416b0d39f" => :sierra
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
	  system "touch ~/.ssh/config; perl -0777 -ne '/#Causes SSH to present your Kryptonite key if paired\\nHost \\*\\n\\tPKCS11Provider \\/usr\\/local\\/lib\\/kr-pkcs11.so/ || exit(1)' ~/.ssh/config || echo #Causes SSH to present your Kryptonite key if paired\\nHost *\\\\n\\\\tPKCS11Provider /usr/local/lib/kr-pkcs11.so >> ~/.ssh/config"
	  system "cp /usr/local/share/kr/co.krypt.krd.plist ~/Library/LaunchAgents"
	  system "launchctl unload ~/Library/LaunchAgents/co.krypt.krd.plist"
	  system "launchctl load ~/Library/LaunchAgents/co.krypt.krd.plist"
  end

   def caveats; <<-EOS.undent
	   kr is now up and running! Type "kr pair" to begin using it.

	   kr can be uninstalled by running 
	   \tlaunchctl unload ~/Library/LaunchAgents/co.krypt.krd.plist ; rm ~/Library/LaunchAgents/co.krypt.krd.plist
	   \tperl -0777 -pi -e 's/#Causes SSH to present your Kryptonite key if paired\\nHost \*\\n\\tPKCS11Provider \/usr\/local\/lib\/kr-pkcs11.so//g' ~/.ssh/config
	   \tbrew uninstall kr
  EOS
  end

end
