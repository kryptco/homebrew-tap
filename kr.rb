class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "2.0.3"

  devel do
	  url "https://github.com/kryptco/kr.git", :tag => "2.0.4"
  end

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "dbcf28b9f00bd0b85d7670ad646aca0d5052bd0785e4f311211ff3bd82d061a8" => :yosemite
	sha256 "aa5eba355ce043899911146b133be01a965a3e5302bd6e4e8a8b8136c49b4f7d" => :el_capitan
	sha256 "67daf0d9f68734afe0183091c6693c697865fac167afa2b303431047b2329767" => :sierra
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
		  system "go", "build", "-ldflags", "-s", "-o", bin/"kr"
	  end
	  cd "src/github.com/kryptco/kr/krd/main" do
		  system "go", "build", "-ldflags", "-s", "-o", bin/"krd"
	  end
	  cd "src/github.com/kryptco/kr/krssh" do
		  system "go", "build", "-ldflags", "-s", "-o", bin/"krssh"
	  end
	  cd "src/github.com/kryptco/kr/pkcs11shim" do
		  system "make"
	  end
	  lib.install "src/github.com/kryptco/kr/pkcs11shim/target/release/kr-pkcs11.so"

	  (share/"kr").install "src/github.com/kryptco/kr/share/kr.png"
	  (share/"kr").install "src/github.com/kryptco/kr/share/co.krypt.krd.plist"

  end

  def post_install
	  system "mkdir -p ~/.ssh"
	  # remove old ssh_config entries
	  system "touch ~/.ssh/config"
	  system "perl -0777 -p -i.bak1 -e 's/\s*#Added by Kryptonite\\nHost \\*\\n\\tPKCS11Provider \\/usr\\/local\\/lib\\/kr-pkcs11.so\\n\\tProxyCommand `find \\/usr\\/local\\/bin\\/krssh 2>\\/dev\\/null \\|\\| which nc` %h %p\\n\\tIdentityFile ~\\/.ssh\\/id_kryptonite\\n\\tIdentityFile ~\\/.ssh\\/id_ed25519\\n\\tIdentityFile ~\\/.ssh\\/id_rsa\\n\\tIdentityFile ~\\/.ssh\\/id_ecdsa\\n\\tIdentityFile ~\\/.ssh\\/id_dsa//g' ~/.ssh/config" 

	  # add current ssh_config
	  system "perl -0777 -ne '/# Added by Kryptonite\\nHost \\*\\n\\tPKCS11Provider \\/usr\\/local\\/lib\\/kr-pkcs11.so\\n\\tProxyCommand \\/usr\\/local\\/bin\\/krssh %h %p\\n\\tIdentityFile ~\\/.ssh\\/id_kryptonite\\n\\tIdentityFile ~\\/.ssh\\/id_ed25519\\n\\tIdentityFile ~\\/.ssh\\/id_rsa\\n\\tIdentityFile ~\\/.ssh\\/id_ecdsa\\n\\tIdentityFile ~\\/.ssh\\/id_dsa/ || exit(1)' ~/.ssh/config || echo \"\\\\n# Added by Kryptonite\\nHost *\\\\n\\\\tPKCS11Provider /usr/local/lib/kr-pkcs11.so\\\\n\\\\tProxyCommand /usr/local/bin/krssh %h %p\\\\n\\\\tIdentityFile ~/.ssh/id_kryptonite\\\\n\\\\tIdentityFile ~/.ssh/id_ed25519\\\\n\\\\tIdentityFile ~/.ssh/id_rsa\\\\n\\\\tIdentityFile ~/.ssh/id_ecdsa\\\\n\\\\tIdentityFile ~/.ssh/id_dsa\" >> ~/.ssh/config"
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
