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
          ETHEREUM_WALLET_PRIVATE_KEY.file = ./secrets/ethereum-wallet-private-key.age; # 0xf7c8e5bFc8DbF27b88D14EF316e7A6418B5d9902
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

        packages = {
          ethereum = pkgs.writeShellScriptBin "ethereum.sh" ''
            pushd "$FLAKE_ROOT/ethereum"
            forge script \
              --rpc-url "https://eth-sepolia.g.alchemy.com/v2/dNcJrI_T39LnG_oMRBZ2i" \
              --private-key "$ETHEREUM_WALLET_PRIVATE_KEY" \
              --broadcast \
              -vvv \
              script/Deploy.sol:DeployEscrow
            popd
          '';
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
            rm -rf $FLAKE_ROOT/ethereum/lib
            mkdir -p $FLAKE_ROOT/ethereum/lib/
            ln -sf ${inputs.forge-std.outPath} $FLAKE_ROOT/ethereum/lib/forge-std
            ${config.pre-commit.installationScript}
          '';
        };
      };
    });
}
