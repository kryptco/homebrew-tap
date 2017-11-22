class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "2.3.0"

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any_skip_relocation
	sha256 "8eb19cae9e600a1fce25c5e8d0b08b7589f26b055c48d998e599558672a9b718" => :el_capitan
	sha256 "0c26baab3c204cdac590f9bb6c2b49d6332b234c2b97991cd41f7524a32f48c5" => :sierra
	sha256 "8c3a76db5d1705be9fe17385580ec740fc2dd88314fa91e4366471c174ae347e" => :high_sierra
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

	  cd "src/github.com/kryptco/kr" do
		  oldPrefix = ENV["PREFIX"]
		  ENV["PREFIX"] = prefix
		  system "make", "install"
		  ENV["PREFIX"] = oldPrefix
	  end

  end
  
   def caveats
	   return "kr is now installed! Run `kr pair` to pair with the Kryptonite app."
   end

end
