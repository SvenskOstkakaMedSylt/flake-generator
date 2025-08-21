{
  inputs = {
    target = {
      type = "path";
      path = ./target;
    };
  };

  outputs = {
    nixpkgs,
    target,
    self,
  }: let
    inherit (nixpkgs) lib;
    systems = lib.systems.flakeExposed;
    forEachSystem = lib.genAttrs systems;
    generateNode = flake:
      {
        original = {
          type = "path";
          path = flake.outPath;
        };

        locked = {
          type = "path";
          path = flake.outPath;
          lastModified = 0;
          inherit (flake) narHash;
        };

        flake = flake._flake or "none" == "flake";
      }
      // (
        if flake ? inputs
        then {
          inputs = builtins.mapAttrs (_: value: value.narHash) flake.inputs;
        }
        else {}
      );

    getInputs = flake:
      {${flake.narHash} = flake;}
      // (lib.mergeAttrsList (map getInputs (builtins.attrValues flake.inputs)));

    allInputs = getInputs target;
    allNodesExceptRoot = builtins.mapAttrs (_: generateNode) allInputs;
    allNodes =
      allNodesExceptRoot
      // {
        root.inputs = {
          target = target.narHash;
        };
      };
  in {
    packages = forEachSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      flake = derivation {
        inherit system;
        name = "source";
        builder = "${pkgs.nushell}/bin/nu";
        args = [./builder.nu];

        nixpkgs = builtins.toString nixpkgs;
        inherit (nixpkgs) narHash;

        flake = ''
          {
            inputs = {
              target.url = "path:${target.outPath}";
            };

            outputs = {target, ...}: target.outputs;
          }
        '';

        lock = builtins.toJSON {
          version = 7;
          root = "root";
          nodes = allNodes;
        };
      };
    });
  };
}
