class Vvctl < Formula
  version "2025.6.25"
  desc "CLI application for Ververica Platform"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.25/vvctl-2025.6.25-aarch64-apple-darwin.tar.gz"
  sha256 "e35268204917a894a43a726ec72662a13738b1df7f4984467e114a34899729ed"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
