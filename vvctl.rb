class Vvctl < Formula
  version "2025.6.24"
  desc "CLI application for Ververica Platform"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.24/vvctl-2025.6.24-aarch64-apple-darwin.tar.gz"
  sha256 "8784f4ae49eb9729c92452fe6ab30be074b131c367ea9d761b4c96c78cf7dfb2"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
