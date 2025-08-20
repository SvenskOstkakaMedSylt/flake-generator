{
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    flake = derivation {
      system = "x86_64-linux";
      name = "source";
      builder = builtins.toString ./empty;
      args = [];
    };
  };
}
