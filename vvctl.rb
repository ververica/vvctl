class Vvctl < Formula
  version "2025.6.1-preview.17"
  desc "Your CLI tool description"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.1-preview.17/vvctl-2025.6.1-preview.17-aarch64-apple-darwin.tar.gz"
  sha256 "fae2c00ee27f69d2b78b286a077342e52ab98bddf1c0c6999352ae1c7a05e6db"  # This value must be updated automatically
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
