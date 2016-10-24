require "language/go"
class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  stable do
	  url "https://github.com/kryptco/kr.git",
      :tag => "1.0.7"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	rebuild 1
    sha256 "cfeb3bb5bcb0939bd1831edb5cdfd08f7a9ba3146ae50948ded0c53351a7962c" => :el_capitan
	sha256 "e307bcaf1310241c151b23c9f8610a289bc1a996726d7853da9706dde20258ca" => :sierra
	sha256 "8cc6a9577a7762e09ad5ea06993ab12e8c1effd80266eacaa2e2e0e4c67ae21a" => :yosemite
  end

  devel do
	  url "https://github.com/agrinman/kr.git", :using => :git
  end

  head do
	  url "https://github.com/agrinman/kr.git"
  end

  option "HEAD", "Install HEAD revision"

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
