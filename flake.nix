{
  description = "vvctl - Ververica Platform CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      version = "2026.11.1"; # Updated by workflow

      # One release tarball per system. The release workflow rewrites each sha256; an empty one
      # means that release has no tarball for the system, and the system is left out below.
      targets = {
        x86_64-linux = { triple = "x86_64-unknown-linux-gnu"; sha256 = "b7ba83b2e0e80091f1f3d834d819180557e5fd27ea826f2fd363858e854a491f"; };
        aarch64-linux = { triple = "aarch64-unknown-linux-gnu"; sha256 = "730b98c480dc17695fcd311c4640387965cb4d3f5a2042c6e7303d92fd262208"; };
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

          # The release binary expects an FHS loader and system libraries; autoPatchelfHook
          # rewrites its interpreter and RPATH to point into the Nix store instead. x86_64 links
          # OpenSSL 3 (libssl.so.3) — openssl_3_5 pins that soname; aarch64 vendors OpenSSL so it
          # gets no OpenSSL RPATH entry.
          nativeBuildInputs = [ pkgs.autoPatchelfHook ];
          buildInputs = [ pkgs.openssl_3_5 pkgs.stdenv.cc.cc.lib ];

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
