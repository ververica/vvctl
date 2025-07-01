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
          version = "2025.6.32"; # Updated by workflow
          
          src = pkgs.fetchurl {
            url = "https://github.com/ververica/vvctl/releases/download/${version}/vvctl-${version}-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "f280349fdcabf5b880e8cd04cb8d60cb3461d42e4c8a034132cb08fc63e829a7"; # Updated by workflow
          };

          sourceRoot = "vvctl-2025.6.32-x86_64-unknown-linux-gnu";

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
