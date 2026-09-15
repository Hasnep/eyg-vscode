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

            eyg-vscode = pkgs.vscode-utils.buildVscodeExtension (finalAttrs: {
              pname = "eyg-vscode";
              version = finalAttrs.src.version;

              vscodeExtPublisher = "hasnep";
              vscodeExtName = "eyg";
              vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

              src = self'.packages.eyg-vscode-vsix;
            });

            eyg-vscode-vsix = pkgs.stdenv.mkDerivation (finalAttrs: {
              name = "eyg-vscode.vsix";
              pname = "eyg-vscode-vsix";
              version = "0.0.0";

              src = pkgs.lib.cleanSource ./.;
              sourceRoot = "source";

              npmDeps = pkgs.fetchNpmDeps {
                name = "${finalAttrs.pname}-npm-deps";
                src = finalAttrs.src;
                hash = "sha256-toVN/IYIpq/TmN5lcrmGHEmVIyhzfChcnMtsr5LbYd0=";
              };

              nativeBuildInputs = [
                # keep-sorted start
                pkgs.imagemagick
                pkgs.just
                pkgs.nodejs-slim
                pkgs.nodejs-slim.npm
                pkgs.pkg-config
                pkgs.vsce
                pkgs.writableTmpDirAsHomeHook
                # keep-sorted end
              ];
              buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.libsecret ];

              strictDeps = true;

              buildPhase = ''
                runHook preBuild
                just build
                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall
                cp build/eyg-vscode-${finalAttrs.version}.vsix $out
                runHook postInstall
              '';
            });
          };

          devShells.default = pkgs.mkShell {
            packages = self'.packages.eyg-vscode-vsix.nativeBuildInputs ++ [
              # keep-sorted start
              pkgs.actionlint
              pkgs.biome
              pkgs.deadnix
              pkgs.just
              pkgs.keep-sorted
              pkgs.nixfmt
              pkgs.pre-commit
              pkgs.python3
              pkgs.python3Packages.pre-commit-hooks
              pkgs.ratchet
              pkgs.rumdl
              pkgs.shellcheck
              pkgs.vsce
              pkgs.xvfb-run
              pkgs.yamlfix
              pkgs.zizmor
              # keep-sorted end
            ];
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
