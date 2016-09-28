require "language/go"
class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  version "1.0.0"
  head "https://github.com/agrinman/kr.git"
  url "-"

  bottle do
	# TODO: add bottle URL since its non-standard
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
    sha256 "0c52891dc82852665cf3b8d2d5e654d5b81ca4e7af9900488a5a090369313046" => :el_capitan
	sha256 "cd515f1eeae0635410d1f898ed5de0956d0416b322d7982f89126e2581d6959c" => :sierra
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
	  system "perl -0777 -ne '/Host \\*\\n\\tPKCS11Provider \\/usr\\/local\\/lib\\/kr-pkcs11.so/ || exit(1)' ~/.ssh/config || echo Host *\\\\n\\\\tPKCS11Provider /usr/local/lib/kr-pkcs11.so >> ~/.ssh/config"
	  system "cp /usr/local/share/kr/co.krypt.krd.plist ~/Library/LaunchAgents"
	  system "launchctl unload ~/Library/LaunchAgents/co.krypt.krd.plist"
	  system "launchctl load ~/Library/LaunchAgents/co.krypt.krd.plist"
  end

   def caveats; <<-EOS.undent
	   kr is now up and running! Type "kr pair" to begin using it.

	   kr can be uninstalled by running 
	   \tlaunchctl unload ~/Library/LaunchAgents/co.krypt.krd.plist ; rm ~/Library/LaunchAgents/co.krypt.krd.plist
	   \tperl -0777 -pi -e 's/Host \*\\n\\tPKCS11Provider \/usr\/local\/lib\/kr-pkcs11.so//g' ~/.ssh/config
	   \tbrew uninstall kr
  EOS
  end

end
