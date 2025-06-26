class Vvctl < Formula
  version "2025.6.26"
  desc "CLI application for Ververica Platform"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.26/vvctl-2025.6.26-aarch64-apple-darwin.tar.gz"
  sha256 "a04b6872d33b5a8e502a55f1774d211929fd5142ad9b1683ecd2f545e3fc3ef7"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
