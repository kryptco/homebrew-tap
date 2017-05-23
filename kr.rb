class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "2.1.0"

  devel do
	  url "https://github.com/kryptco/kr.git", :tag => "2.1.0"
  end

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "0d1bfa1c215a10e377a6ba3c6cbb7f98a80b59c213cac7b0f533451843e0eb05" => :yosemite
	sha256 "3bbc2fac967d7c26f0e6b65a07a447683d235afb589159691a790423e39e82af" => :el_capitan
	sha256 "5af8c26ae54f8cd804711cfb3ee7e5cec20e04f9029c3a2f6c791d71f3bbb1f5" => :sierra
  end

  depends_on "rust" => :build
  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on "libsodium"

  option "without-ssh-config", "Do not modify ~/.ssh/config"

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
	  escaped_prefix = HOMEBREW_PREFIX.to_s.gsub '/', '\\/'
	  if build.without? "ssh-config"
	  else
		  system "mkdir -p ~/.ssh"
		  # remove old ssh_config entries
		  system "touch ~/.ssh/config"
		  system "perl -0777 -p -i.bak1 -e 's/\s*#Added by Kryptonite\\nHost \\*\\n\\tPKCS11Provider \\/usr\\/local\\/lib\\/kr-pkcs11.so\\n\\tProxyCommand `find \\/usr\\/local\\/bin\\/krssh 2>\\/dev\\/null \\|\\| which nc` %h %p\\n\\tIdentityFile ~\\/.ssh\\/id_kryptonite\\n\\tIdentityFile ~\\/.ssh\\/id_ed25519\\n\\tIdentityFile ~\\/.ssh\\/id_rsa\\n\\tIdentityFile ~\\/.ssh\\/id_ecdsa\\n\\tIdentityFile ~\\/.ssh\\/id_dsa//g' ~/.ssh/config" 

		  # add current ssh_config
		  system "perl -0777 -ne '/# Added by Kryptonite\\nHost \\*\\n\\tPKCS11Provider #{escaped_prefix}\\/lib\\/kr-pkcs11.so\\n\\tProxyCommand #{escaped_prefix}\\/bin\\/krssh %h %p\\n\\tIdentityFile ~\\/.ssh\\/id_kryptonite\\n\\tIdentityFile ~\\/.ssh\\/id_ed25519\\n\\tIdentityFile ~\\/.ssh\\/id_rsa\\n\\tIdentityFile ~\\/.ssh\\/id_ecdsa\\n\\tIdentityFile ~\\/.ssh\\/id_dsa/ || exit(1)' ~/.ssh/config || echo \"\\\\n# Added by Kryptonite\\nHost *\\\\n\\\\tPKCS11Provider #{HOMEBREW_PREFIX}/lib/kr-pkcs11.so\\\\n\\\\tProxyCommand #{HOMEBREW_PREFIX}/bin/krssh %h %p\\\\n\\\\tIdentityFile ~/.ssh/id_kryptonite\\\\n\\\\tIdentityFile ~/.ssh/id_ed25519\\\\n\\\\tIdentityFile ~/.ssh/id_rsa\\\\n\\\\tIdentityFile ~/.ssh/id_ecdsa\\\\n\\\\tIdentityFile ~/.ssh/id_dsa\" >> ~/.ssh/config"
	  end
	  system "mkdir -p ~/Library/LaunchAgents; cat #{prefix}/share/kr/co.krypt.krd.plist | sed -E 's/\\/usr\\/local/#{escaped_prefix}/g' > ~/Library/LaunchAgents/co.krypt.krd.plist"
	  system "kr restart"
  end

   def caveats
	   if build.without? "ssh-config"
		   return <<-EOS.undent
	   Please add the following to your ssh config:

	   # Added by Kryptonite
	   Host *
	   \tPKCS11Provider #{HOMEBREW_PREFIX}/lib/kr-pkcs11.so
	   \tProxyCommand #{HOMEBREW_PREFIX}/bin/krssh %h %p
	   \tIdentityFile ~/.ssh/id_kryptonite
	   \tIdentityFile ~/.ssh/id_ed25519
	   \tIdentityFile ~/.ssh/id_rsa
	   \tIdentityFile ~/.ssh/id_ecdsa
	   \tIdentityFile ~/.ssh/id_dsa

	   kr is now up and running! Type "kr pair" to begin using it.
	   kr can be uninstalled by running "kr uninstall"
		   EOS
	   else
		   return <<-EOS.undent
	   kr is now up and running! Type "kr pair" to begin using it.
	   kr can be uninstalled by running "kr uninstall"
		   EOS
	   end
  end

end
