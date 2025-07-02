{
  description = "vvctl - Ververica Platform CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "vvctl";
          version = "2025.6.37"; # Updated by workflow
          
          src = pkgs.fetchurl {
            url = "https://github.com/ververica/vvctl/releases/download/${version}/vvctl-${version}-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "e8edd59a6bdb57bf6132ad21c3a539d8cd799b42ce89bb0a8a4f1b668cf8397f"; # Updated by workflow
          };

          sourceRoot = "vvctl-2025.6.37-x86_64-unknown-linux-gnu";

          installPhase = ''
            runHook preInstall
            install -D vvctl $out/bin/vvctl
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Ververica Platform CLI";
            homepage = "https://github.com/ververica/vvctl";
            license = licenses.asl20;
            maintainers = [ ];
            platforms = [ "x86_64-linux" ];
            mainProgram = "vvctl";
          };
        };
      });
}
