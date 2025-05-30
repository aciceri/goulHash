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
          };
        };


        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            inputs'.aiken.packages.aiken
            bun
            age
          ];

          inputsFrom = [ config.flake-root.devShell ];

          shellHook = ''
            ${config.pre-commit.installationScript}
            source ${lib.getExe config.agenix-shell.installationScript}
          '';
        };
      };
    });
}
