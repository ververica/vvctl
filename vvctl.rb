class Vvctl < Formula
  version "2025.6.1-preview.20"
  desc "CLI application for Ververica Platform"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.1-preview.20/vvctl-2025.6.1-preview.20-aarch64-apple-darwin.tar.gz"
  sha256 "13c3eacb7d7ba8c66fb6a5e9bddf19c9e6aa420b6911d0def99e7f2fad07e6b6"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
