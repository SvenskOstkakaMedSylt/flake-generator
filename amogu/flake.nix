{
    inputs = {
        nixpkgs.url = "/nix/store/0nhqsm3lzxj71a9asqy05l1v9y7pqfc1-source";
    };
    
    outputs = {nixpkgs, ...}: {
        test = nixpkgs.packages."x86_64-linux".nushell;
    };
}