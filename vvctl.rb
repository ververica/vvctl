class Vvctl < Formula
  version "2025.6.1-preview.21"
  desc "CLI application for Ververica Platform"
  homepage "https://app.ververica.cloud/"
  url "https://github.com/ververica/vvctl/releases/download/2025.6.1-preview.21/vvctl-2025.6.1-preview.21-aarch64-apple-darwin.tar.gz"
  sha256 "d980cee3c72705de08eec9191f684ecf443773193c30481d12c288bfaac15bb2"
  license "Your-License"

  def install
    bin.install "vvctl"
  end

  test do
    system "#{bin}/vvctl", "--version"
  end
end
