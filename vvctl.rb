class Vvctl < Formula
  version "2025.6.23"
  desc "CLI application for Ververica Platform"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.23/vvctl-2025.6.23-aarch64-apple-darwin.tar.gz"
  sha256 "3387d25b1ac255d9d028e4c47c3e69cc17ae95533a88b5b77a0525ad1f8f9d7a"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
