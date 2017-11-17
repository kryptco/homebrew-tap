class Kr < Formula
  desc "Kryptonite command line client, daemon, and SSH integration"
  homepage "https://krypt.co"
  url "https://github.com/kryptco/kr.git", :tag => "2.3.0"

  devel do
	  url "https://github.com/kryptco/kr.git", :tag => "2.3.0"
  end

  head do
	  url "https://github.com/kryptco/kr.git"
  end

  bottle do
	root_url "https://github.com/kryptco/bottles/raw/master"
	cellar :any
	sha256 "d89cfdc8db838d646ab51ee4204b2ba313301ef8089bbc86845e49b36414dbbb" => :el_capitan
	sha256 "b966f81d976b8393d1bc43a0ceb8220f3d6615578aa04d72a6ed5b1298b7c7a2" => :sierra
	sha256 "fef88203d2f9b4cf3b381e3694e49f3b6a3493203a4c56701e6605f2754eb0de" => :high_sierra
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
  
  def post_install
  end

   def caveats
	   return "kr is now installed! Run `kr pair` to pair with the Kryptonite app."
   end

end
