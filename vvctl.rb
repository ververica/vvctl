class Vvctl < Formula
  version "2025.3.3"
  desc "Your CLI tool description"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvc-cli/releases/download/#{version}/vvctl-#{version}-aarch64-apple-darwin.tar.gz"
  sha256 "PLACEHOLDER_FOR_SHA256"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
