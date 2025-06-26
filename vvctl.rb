class Vvctl < Formula
  version "2025.6.22"
  desc "CLI application for Ververica Platform"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.22/vvctl-2025.6.22-aarch64-apple-darwin.tar.gz"
  sha256 "c2be63ae4a94fc609f4d29f5329a0f2d32d4ac4df08970904087d6b7b3be7efe"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
