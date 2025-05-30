{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-shell.url = "github:aciceri/agenix-shell";
    flake-root.url = "github:srid/flake-root";
    aiken.url = "github:aiken-lang/aiken";
    forge-std = {
      flake = false;
      url = "github:foundry-rs/forge-std/v1.9.7";
    };
    cross-chain-swaps = {
      flake = false;
      url = "github:1inch/cross-chain-swap";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ config, lib, ... }: {
      systems = [ "x86_64-linux" ];

      imports = with inputs; [
        git-hooks.flakeModule
        treefmt-nix.flakeModule
        flake-root.flakeModule
        agenix-shell.flakeModules.agenix-shell
      ];

      agenix-shell = {
        secrets = {
          BLOCKFROST_API_KEY.file = ./secrets/blockfrost-api-key.age;
        };
      };

      perSystem = { config, pkgs, inputs', ... }: {
        treefmt.config = {
          flakeFormatter = true;
          flakeCheck = true;
          programs = {
            nixpkgs-fmt.enable = true;
            prettier.enable = true;
          };
        };

        pre-commit = {
          check.enable = false;
          settings.hooks = {
            treefmt = {
              enable = true;
              package = config.treefmt.build.wrapper;
            };
            aiken = {
              enable = true;
              files = "\\.ak$";
              entry = "aiken fmt";
            };
            solidity = {
              enable = true;
              files = "\\.sol$";
              entry = "forge fmt";
            };
          };
        };


        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            inputs'.aiken.packages.aiken
            bun
            foundry
            age
          ];

          inputsFrom = [ config.flake-root.devShell ];

          shellHook = ''
            source ${lib.getExe config.agenix-shell.installationScript}

            # forge will use this directory to download the solc compilers
            mkdir -p $HOME/.svm

            # forge needs forge-std to work
            mkdir -p $FLAKE_ROOT/ethereum/lib/
            ln -sf ${inputs.forge-std.outPath} $FLAKE_ROOT/ethereum/lib/forge-std
            ln -sf ${inputs.cross-chain-swaps.outPath} $FLAKE_ROOT/ethereum/lib/cross-chain-swaps

            ${config.pre-commit.installationScript}
          '';
        };
      };
    });
}
