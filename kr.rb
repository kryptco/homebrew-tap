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
	rebuild 8
	sha256 "5688792e79692a5873b2eab249e39b57c34aac9979c19e96f6c895274d6990f2" => :el_capitan
	sha256 "07aaf8b57e1e8c52efff7749498d448397296def6abb3bb5f28bec17a567d104" => :sierra
	sha256 "2fe93574d959031ae572b0119215156f3d653dfe15f865190b5c33cfdc655045" => :high_sierra
  end

  depends_on "rust" => :build
  depends_on "go" => :build
  depends_on "pkg-config" => :build
  depends_on :xcode => :build

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
