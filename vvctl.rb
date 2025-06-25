class Vvctl < Formula
  version "2025.6.1-preview.18"
  desc "Your CLI tool description"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.1-preview.18/vvctl-2025.6.1-preview.18-aarch64-apple-darwin.tar.gz"
  sha256 "7d7da39c1f23f6c35558fb5d4f69ed06e53788316180cbea9a7cd2964a726f4e"  # This value must be updated automatically
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
