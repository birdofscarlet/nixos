{
  description = "birdofscarlet's Niri Flake System";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      mkHost =
        hostname: homeFile:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs hostname; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs hostname; };
                users.cardinal = import homeFile;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        alicebox = mkHost "alicebox" ./hosts/alicebox/home.nix;
        alicepad = mkHost "alicepad" ./hosts/alicepad/home.nix;
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
