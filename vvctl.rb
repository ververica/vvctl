class Vvctl < Formula
  version "2025.6.1-preview.13"
  desc "Your CLI tool description"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvc-cli/releases/download/2025.6.1-preview.13/vvctl-2025.6.1-preview.13-aarch64-apple-darwin.tar.gz"
  sha256 "ab7b2a8ccb884736b0c1cf5848e235da0876698323ed3e631b68add1ddb8c2e1"  # This value must be updated automatically
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
