{
  description = "nixosTest playground";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        pkgs = nixpkgs.legacyPackages.${system};

        # nixosTests
        basic = pkgs.callPackage ./basic {};
        client-server = pkgs.callPackage ./client-server {};
      in {
        devShells.default = pkgs.mkShell {
          name = "nix devShell";
          buildInputs = with pkgs;
          with pkgs; [
            nil
            alejandra
          ];
        };

        packages = {
          default = basic;
          inherit
            basic
            client-server
            ;
        };

        checks = {
          inherit
            basic
            client-server
            ;
        };
      };
    };
}
