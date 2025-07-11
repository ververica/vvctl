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
          version = "2025.7.7"; # Updated by workflow
          
          src = pkgs.fetchurl {
            url = "https://github.com/ververica/vvctl/releases/download/${version}/vvctl-${version}-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "f7a20064af1136e6d45161985fe8fbc725b10c719d0548f03b5057952e37386d"; # Updated by workflow
          };

          sourceRoot = "vvctl-2025.7.7-x86_64-unknown-linux-gnu";

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
