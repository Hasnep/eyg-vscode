{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    # nixchequer={url="git+https://codeberg.org/hasnep/nixchequer";   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     flake-parts.follows = "flake-parts";
    #   };};
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      # imports = [ inputs.nixchequer.flakeModule];

      perSystem =
        {
          pkgs,
          self',
          ...
        }:
        {
          packages = {
            default = self'.packages.eyg-vscode;
            eyg-vscode = pkgs.vscode-utils.buildVscodeExtension {
              pname = "eyg-vscode";
              version = "0.0.0";
              vscodeExtPublisher = "hannes";
              vscodeExtName = "eyg";
              vscodeExtUniqueId = "hannes.eyg";

              src = pkgs.lib.cleanSource ./.;
              sourceRoot = "source";

              npmDepsHash = "sha256-toVN/IYIpq/TmN5lcrmGHEmVIyhzfChcnMtsr5LbYd0=";

              nativeBuildInputs = [
                pkgs.imagemagick
                pkgs.just
                pkgs.pkg-config
                pkgs.vsce
              ];

              buildInputs = [ pkgs.libsecret ];

              buildPhase = ''
                just build-logo
              '';
            };
          };

          devShells.default = pkgs.mkShell {
            packages = [
              # keep-sorted start
              pkgs.nodejs
              pkgs.just
              pkgs.xvfb-run
              pkgs.biome
              pkgs.vsce
              # keep-sorted end
            ];
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
