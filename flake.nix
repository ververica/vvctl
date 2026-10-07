{
  description = "vvctl - Ververica Platform CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      version = "2026.10.3"; # Updated by workflow

      # One release tarball per system. The release workflow rewrites each sha256; an empty one
      # means that release has no tarball for the system, and the system is left out below.
      targets = {
        x86_64-linux = { triple = "x86_64-unknown-linux-gnu"; sha256 = "1bfa9f952dfe7a60c14910e996ae0918f84ca7e99163db6cd458174ca7e614da"; };
        aarch64-linux = { triple = "aarch64-unknown-linux-gnu"; sha256 = ""; };
      };

      published = nixpkgs.lib.filterAttrs (_: t: t.sha256 != "") targets;
    in
    flake-utils.lib.eachSystem (builtins.attrNames published) (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        target = published.${system};
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "vvctl";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://github.com/ververica/vvctl/releases/download/${version}/vvctl-${version}-${target.triple}.tar.gz";
            sha256 = target.sha256;
          };

          sourceRoot = "vvctl-${version}-${target.triple}";

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
            platforms = builtins.attrNames published;
            mainProgram = "vvctl";
          };
        };
      });
}
