class Vvctl < Formula
  version "2025.6.1-preview.15"
  desc "Your CLI tool description"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvc-cli/releases/download/2025.6.1-preview.15/vvctl-2025.6.1-preview.15-aarch64-apple-darwin.tar.gz"
  sha256 "bbc500166bd08d87c5437789f6c1efc54786979e2ed7a01d16c83844d977d6c9"  # This value must be updated automatically
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
