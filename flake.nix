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
          version = "2026.2.1"; # Updated by workflow
          
          src = pkgs.fetchurl {
            url = "https://github.com/ververica/vvctl/releases/download/${version}/vvctl-${version}-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "338d1a3a0ac1435603befd78d3697b369aaf4426108cecddc85fa3494c6c9a1d"; # Updated by workflow
          };

          sourceRoot = "vvctl-2026.2.1-x86_64-unknown-linux-gnu";

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
